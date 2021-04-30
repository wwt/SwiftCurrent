//
//  AnyWorkflow.swift
//  
//
//  Created by Tyler Thompson on 11/25/20.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation

public class AnyWorkflow: LinkedList<FlowRepresentableMetadata> {
    public typealias InstanceNode = LinkedList<AnyFlowRepresentable?>.Element
    public typealias ArrayLiteralElement = AnyFlowRepresentable.Type
    internal var instances = LinkedList<AnyFlowRepresentable?>()
    internal var orchestrationResponder: AnyOrchestrationResponder?

    public var firstLoadedInstance: LinkedList<AnyFlowRepresentable?>.Element?

    public func applyOrchestrationResponder(_ orchestrationResponder: AnyOrchestrationResponder) {
        self.orchestrationResponder = orchestrationResponder
    }

    @discardableResult public func launch(withLaunchStyle launchStyle: LaunchStyle = .default,
                                          onFinish: ((Any?) -> Void)? = nil) -> LinkedList<AnyFlowRepresentable?>.Element? {
        launch(passedArgs: .none, withLaunchStyle: launchStyle, onFinish: onFinish)
    }

    @discardableResult public func launch(with args: Any?,
                                          withLaunchStyle launchStyle: LaunchStyle = .default,
                                          onFinish: ((Any?) -> Void)? = nil) -> LinkedList<AnyFlowRepresentable?>.Element? {
        launch(passedArgs: .args(args), withLaunchStyle: launchStyle, onFinish: onFinish)
    }

    @discardableResult public func launch(passedArgs: PassedArgs,
                                          withLaunchStyle launchStyle: LaunchStyle = .default,
                                          onFinish: ((Any?) -> Void)? = nil) -> LinkedList<AnyFlowRepresentable?>.Element? {
        removeInstances()
        instances = LinkedList(map { _ in nil })
        var root: (instance: AnyFlowRepresentable, metadata: FlowRepresentableMetadata)?
        var passedArgs = passedArgs

        let metadata = first?.traverse { [self] nextNode in
            let nextMetadata = nextNode.value
            let flowRepresentable = nextMetadata.flowRepresentableFactory()
            flowRepresentable.workflow = self
            flowRepresentable.proceedInWorkflowStorage = { passedArgs = $0 }

            let shouldLoad = flowRepresentable.shouldLoad(with: passedArgs)

            defer {
                guard let instance = instances.first?.traverse(nextNode.position) else { fatalError("Internal state of workflow completely mangled during launch.") }
                let persistence = nextMetadata.calculatePersistence(passedArgs)
                if shouldLoad {
                    firstLoadedInstance = instance
                    firstLoadedInstance?.value = flowRepresentable
                    setupCallbacks(for: instance, onFinish: onFinish)
                } else if !shouldLoad && persistence == .persistWhenSkipped {
                    instance.value = flowRepresentable
                    setupCallbacks(for: instance, onFinish: onFinish)
                    orchestrationResponder?.launchOrProceed(to: (instance: instance, metadata: nextMetadata), from: convertInput(root))
                    root = (instance: flowRepresentable, metadata: nextMetadata)
                }
            }
            return shouldLoad
        }?.value

        guard let first = firstLoadedInstance,
              let m = metadata else {
            if let argsToPass = passedArgs.extract(nil) {
                onFinish?(argsToPass)
            }
            return nil
        }

        orchestrationResponder?.launchOrProceed(to: (instance: first, metadata:m), from: convertInput(root))

        return firstLoadedInstance
    }

    /// abandon: Called when the workflow should be terminated, and the app should return to the point before the workflow was launched
    /// - Parameter animated: A boolean indicating whether abandoning the workflow should be animated
    /// - Parameter onFinish: A callback after the workflow has been abandoned.
    /// - Returns: Void
    /// - Note: In order for this to function the workflow must have a presenter, presenters must call back to the workflow to inform when the abandon process has finished for the onFinish callback to be called.
    public func abandon(animated: Bool = true, onFinish:(() -> Void)? = nil) {
        orchestrationResponder?.abandon(self, animated: animated) { [self] in
            removeInstances()
            firstLoadedInstance = nil
            orchestrationResponder = nil
            onFinish?()
        }
    }

    deinit {
        removeInstances()
        orchestrationResponder = nil
    }

    private func removeInstances() {
        instances.forEach { $0.value?.proceedInWorkflowStorage = nil }
        instances.removeAll()
        firstLoadedInstance = nil
    }

    private func setupProceedCallbacks(_ node: LinkedList<AnyFlowRepresentable?>.Element, _ onFinish: ((Any?) -> Void)?) {
        guard let currentMetadataNode = first?.traverse(node.position) else {
            fatalError("Internal state of workflow completely mangled during configuration of proceed callbacks.")
        }
        node.value?.proceedInWorkflowStorage = { [self] args in
            var argsToPass = args
            var viewToPresent: (instance: AnyFlowRepresentable, metadata: FlowRepresentableMetadata)?
            let nextLoadedNode = node.next?.traverse { nextNode in
                guard let metadata = first?.traverse(nextNode.position)?.value else { return false }
                let persistence = metadata.calculatePersistence(argsToPass)
                let flowRepresentable = metadata.flowRepresentableFactory()
                flowRepresentable.workflow = self

                flowRepresentable.proceedInWorkflowStorage = { argsToPass = $0 }

                let shouldLoad = flowRepresentable.shouldLoad(with: argsToPass)
                nextNode.value = (shouldLoad || (!shouldLoad && persistence == .persistWhenSkipped)) ? flowRepresentable : nil

                if !shouldLoad && persistence == .persistWhenSkipped {
                    nextNode.value = flowRepresentable
                    viewToPresent = (instance: flowRepresentable, metadata: metadata)
                    setupCallbacks(for: nextNode, onFinish: onFinish)
                    orchestrationResponder?.proceed(to: (instance: nextNode, metadata: metadata),
                                                    from: (instance: node, metadata: currentMetadataNode.value))
                }

                return shouldLoad
            }

            guard let nextNode = nextLoadedNode,
                  let nextMetadataNode = first?.traverse(nextNode.position) else {
                onFinish?(argsToPass.extract(nil))
                return
            }

            setupCallbacks(for: nextNode, onFinish: onFinish)
            orchestrationResponder?.proceed(to: (instance: nextNode, metadata:nextMetadataNode.value),
                                            from: convertInput(viewToPresent) ?? (instance: node, metadata:currentMetadataNode.value))
        }
    }

    private func setupProceedBackwardCallbacks(_ node: LinkedList<AnyFlowRepresentable?>.Element, _ onFinish: ((Any?) -> Void)?) {
        guard let currentMetadataNode = first?.traverse(node.position) else {
            fatalError("Internal state of workflow completely mangled during configuration of proceed backward callbacks.")
        }
        node.value?.proceedBackwardInWorkflowStorage = { [self] in
            let previousLoadedNode = node.traverse(direction: .backward) { previousNode in
                previousNode.value != nil
            }

            guard let previousNode = previousLoadedNode else { return }

            guard let previousMetadataNode = first?.traverse(previousNode.position) else {
                fatalError("Internal state of workflow completely mangled during execution of proceed backward callback.")
            }

            orchestrationResponder?.proceedBackward(from: (instance: node, metadata: currentMetadataNode.value), to: (instance: previousNode, metadata: previousMetadataNode.value))
        }
    }

    private func setupCallbacks(for node: LinkedList<AnyFlowRepresentable?>.Element, onFinish: ((Any?) -> Void)?) {
        setupProceedCallbacks(node, onFinish)
        setupProceedBackwardCallbacks(node, onFinish)
    }
}

extension AnyWorkflow {
    private func convertInput(_ old: (instance: AnyFlowRepresentable,
                                      metadata: FlowRepresentableMetadata)?) -> (instance: AnyWorkflow.InstanceNode,
                                                                                 metadata: FlowRepresentableMetadata)? {
        guard let old = old else { return nil }
        return (instance: AnyWorkflow.InstanceNode(with: old.instance), metadata: old.metadata)
    }
}

extension AnyWorkflow {
    public enum PassedArgs {
        case none
        case args(Any?)

        public func extract(_ defaultValue: Any?) -> Any? {
            if case .args(let value) = self {
                return value
            }
            return defaultValue
        }
    }
}
