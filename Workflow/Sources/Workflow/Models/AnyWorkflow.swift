//
//  AnyWorkflow.swift
//  
//
//  Created by Tyler Thompson on 11/25/20.
//

import Foundation

public class AnyWorkflow: LinkedList<FlowRepresentableMetaData> {
    public typealias InstanceNode = LinkedList<AnyFlowRepresentable?>.Element
    public typealias ArrayLiteralElement = AnyFlowRepresentable.Type
    internal var instances = LinkedList<AnyFlowRepresentable?>()
    internal var orchestrationResponder: AnyOrchestrationResponder?

    public var firstLoadedInstance: LinkedList<AnyFlowRepresentable?>.Element?

    deinit {
        removeInstances()
        orchestrationResponder = nil
    }

    public func applyOrchestrationResponder(_ orchestrationResponder: AnyOrchestrationResponder) {
        self.orchestrationResponder = orchestrationResponder
    }

    public func launch(from: (instance: AnyFlowRepresentable, metadata: FlowRepresentableMetaData)?,
                       with args: Any?,
                       withLaunchStyle launchStyle: PresentationType = .default,
                       onFinish: ((Any?) -> Void)? = nil) -> LinkedList<AnyFlowRepresentable?>.Element? {
        postDataForTestListeners(from: from,
                                 with: args,
                                 withLaunchStyle: launchStyle,
                                 onFinish: onFinish)
        removeInstances()
        instances = LinkedList(map { _ in nil })
        var root: (instance: AnyFlowRepresentable, metadata: FlowRepresentableMetaData)?
        var passedArgs: PassedArgs = .none

        let metadata = first?.traverse { node in
            let metadata = node.value
            var flowRepresentable = metadata.flowRepresentableType.instance()
            flowRepresentable.workflow = self
            flowRepresentable.proceedInWorkflowStorage = { passedArgs = .args($0) }
            let shouldLoad = flowRepresentable.erasedShouldLoad(with: passedArgs.extract(args))

            defer {
                guard let instance = instances.first?.traverse(node.position) else { fatalError("Internal state of workflow completely mangled somehow...") }
                let persistance = metadata.calculatePersistance(args)
                if shouldLoad {
                    firstLoadedInstance = instance
                    firstLoadedInstance?.value = flowRepresentable
                    self.setupCallbacks(for: instance, onFinish: onFinish)
                } else if !shouldLoad && persistance == .persistWhenSkipped {
                    root = (instance: flowRepresentable, metadata: metadata)
                    instance.value = flowRepresentable
                    self.setupCallbacks(for: instance, onFinish: onFinish)
                    self.orchestrationResponder?.proceed(to: (instance: instance, metadata: metadata), from: convertInput(from))
                }

            }
            return shouldLoad
        }?.value

        guard let first = firstLoadedInstance,
              let m = metadata else {
                if let argsToPass = passedArgs.extract(args) {
                    onFinish?(argsToPass)
                }
                return nil
        }

        orchestrationResponder?.proceed(to: (instance: first, metadata:m), from: convertInput(root) ?? convertInput(from))
        return firstLoadedInstance
    }

    /// abandon: Called when the workflow should be terminated, and the app should return to the point before the workflow was launched
    /// - Parameter animated: A boolean indicating whether abandoning the workflow should be animated
    /// - Parameter onFinish: A callback after the workflow has been abandoned.
    /// - Returns: Void
    /// - Note: In order for this to function the workflow must have a presenter, presenters must call back to the workflow to inform when the abandon process has finished for the onFinish callback to be called.
    public func abandon(animated: Bool = true, onFinish:(() -> Void)? = nil) {
        orchestrationResponder?.abandon(self, animated: animated, onFinish: {
            self.removeInstances()
            self.firstLoadedInstance = nil
            self.orchestrationResponder = nil
            onFinish?()
        })
    }

    private func removeInstances() {
        instances.forEach { $0.value?.proceedInWorkflowStorage = nil }
        instances.removeAll()
        firstLoadedInstance = nil
    }

    private func replaceInstance(atIndex index: Int, withInstance instance: AnyFlowRepresentable?) {
        instances.replace(atIndex: index, withItem: instance)
    }

    private func setupCallbacks(for node: LinkedList<AnyFlowRepresentable?>.Element, onFinish: ((Any?) -> Void)?) {
        guard let currentMetadataNode = first?.traverse(node.position) else { fatalError("Internal state of workflow completely mangled somehow...") }
        node.value?.proceedInWorkflowStorage = { [self] args in
            var argsToPass = args
            var viewToPresent: (instance: AnyFlowRepresentable, metadata: FlowRepresentableMetaData)?
            let nextLoadedNode = node.next?.traverse { nextNode in
                guard let metadata = first?.traverse(nextNode.position)?.value else { return false }
                let persistance = metadata.calculatePersistance(argsToPass)
                var flowRepresentable = metadata.flowRepresentableType.instance()
                flowRepresentable.workflow = self

                nextNode.value = flowRepresentable
                flowRepresentable.proceedInWorkflowStorage = { argsToPass = $0 }

                let shouldLoad = flowRepresentable.erasedShouldLoad(with: argsToPass) == true
                if !shouldLoad && persistance == .persistWhenSkipped {
                    viewToPresent = (instance: flowRepresentable, metadata: metadata)
                    self.setupCallbacks(for: nextNode, onFinish: onFinish)
                    self.orchestrationResponder?.proceed(to: (instance: nextNode, metadata: metadata),
                                                         from: (instance: node, metadata: currentMetadataNode.value))
                }

                return shouldLoad
            }

            guard let nextNode = nextLoadedNode,
                  let nextMetadataNode = first?.traverse(nextNode.position) else {
                onFinish?(argsToPass)
                return
            }

            self.setupCallbacks(for: nextNode, onFinish: onFinish)
            orchestrationResponder?.proceed(to: (instance: nextNode, metadata:nextMetadataNode.value),
                                            from: convertInput(viewToPresent) ?? (instance: node, metadata:currentMetadataNode.value))
        }
    }
}

extension AnyWorkflow {
    private func postDataForTestListeners(from: Any?,
                                          with args: Any?,
                                          withLaunchStyle launchStyle: PresentationType = .default,
                                          onFinish: ((Any?) -> Void)? = nil) {
        #if DEBUG
        if NSClassFromString("XCTest") != nil {
            NotificationCenter.default.post(name: .workflowLaunched, object: [
                "workflow": self,
                "launchFrom": from,
                "args": args,
                "style": launchStyle,
                "onFinish": onFinish
            ])
        }
        #endif
    }

    private func convertInput(_ old: (instance: AnyFlowRepresentable,
                                      metadata: FlowRepresentableMetaData)?) -> (instance: AnyWorkflow.InstanceNode,
                                                                                 metadata: FlowRepresentableMetaData)? {
        guard let old = old else { return nil }
        return (instance: AnyWorkflow.InstanceNode(with: old.instance), metadata: old.metadata)
    }
}

extension AnyWorkflow {
    private enum PassedArgs {
        case none
        case args(Any?)

        func extract(_ defaultValue: Any?) -> Any? {
            if case .args(let value) = self {
                return value
            }
            return defaultValue
        }
    }
}
