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

    public init() {
        super.init(nil)
    }

    required init(_ node: Element?) {
        super.init(node)
    }

    deinit {
        removeInstances()
        orchestrationResponder = nil
    }

    public func applyOrchestrationResponder(_ orchestrationResponder: AnyOrchestrationResponder) {
        self.orchestrationResponder = orchestrationResponder
    }

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

    public func launch(from: (instance: AnyFlowRepresentable, metadata: FlowRepresentableMetaData)?,
                       with args: Any?,
                       withLaunchStyle launchStyle: PresentationType = .default,
                       onFinish: ((Any?) -> Void)? = nil) -> LinkedList<AnyFlowRepresentable?>.Element? {
        postDataForTestListeners(from: from,
                                 with: args,
                                 withLaunchStyle: launchStyle,
                                 onFinish: onFinish)
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
                let position = node.position
                if shouldLoad {
                    instances.replace(atIndex: position, withItem: flowRepresentable)
                    firstLoadedInstance = instances.first?.traverse(position)
                    if let firstLoadedInstance = firstLoadedInstance {
                        self.setupCallbacks(for: firstLoadedInstance,
                                            shouldDestroy: metadata.calculatePersistance(args) == FlowPersistance.removedAfterProceeding,
                                            onFinish: onFinish)
                    }
                } else if !shouldLoad && metadata.calculatePersistance(args) == .persistWhenSkipped {
                    var reference: ((Any?) -> Void)?
                    self.handleCallbackWhenHiddenInitially(viewToPresent: &root,
                                                           hold: &reference,
                                                           instance: flowRepresentable,
                                                           instancePosition: position,
                                                           from: from,
                                                           metadata: metadata,
                                                           onFinish: onFinish)
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
        orchestrationResponder?.abandon(self, animated: animated, onFinish: { [weak self] in
            self?.removeInstances()
            self?.firstLoadedInstance = nil
            self?.orchestrationResponder = nil
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

    private func setupCallbacks(for node: LinkedList<AnyFlowRepresentable?>.Element, shouldDestroy: Bool = false, onFinish: ((Any?) -> Void)?) {
        guard let currentMetadataNode = first?.traverse(node.position) else { return }
        node.value?.proceedInWorkflowStorage = { [self] args in
            var argsToPass = args
            var viewToPresent: (instance: AnyFlowRepresentable, metadata: FlowRepresentableMetaData)?
            let nextLoadedNode = node.next?.traverse {
                let index = $0.position
                guard let metadata = first?.traverse(index)?.value else { return false }
                var instance = metadata.flowRepresentableType.instance()
                instance.proceedInWorkflowStorage = $0.value?.proceedInWorkflowStorage
                instance.workflow = self

                var hold = instance.proceedInWorkflowStorage
                defer {
                    instance.proceedInWorkflowStorage = hold
                    replaceInstance(atIndex: index, withInstance: instance)
                }

                instance.proceedInWorkflowStorage = { argsToPass = $0 }

                let persistance = metadata.calculatePersistance(argsToPass)

                let shouldLoad = instance.erasedShouldLoad(with: argsToPass) == true
                if !shouldLoad && persistance == .persistWhenSkipped {
                    handleCallbackWhenHiddenInitially(viewToPresent: &viewToPresent,
                                                           hold: &hold,
                                                           instance: instance,
                                                           instancePosition: index,
                                                           from: (instance: node.value!, metadata: currentMetadataNode.value),
                                                           metadata: metadata,
                                                           onFinish: onFinish)
                }

                return shouldLoad
            }

            guard let nextNode = nextLoadedNode,
                  let nextMetadataNode = first?.traverse(nextNode.position) else {
                onFinish?(argsToPass)
                return
            }

            let nextMetadata = nextMetadataNode.value
            let currentMetadata = currentMetadataNode.value
            let nextPersistance = nextMetadata.calculatePersistance(argsToPass)

            self.setupCallbacks(for: nextNode,
                                shouldDestroy: nextPersistance == FlowPersistance.removedAfterProceeding,
                                onFinish: onFinish)

            let vtpLauncher:(instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)? = {
                guard let root = viewToPresent else { return nil }
                return (instance: AnyWorkflow.InstanceNode(with: root.instance), metadata: root.metadata)
            }()

            orchestrationResponder?.proceed(to: (instance: nextNode, metadata:nextMetadata),
                                            from: vtpLauncher ?? (instance: node, metadata:currentMetadata))
        }
    }

    private func handleCallbackWhenHiddenInitially(viewToPresent:inout (instance: AnyFlowRepresentable, metadata: FlowRepresentableMetaData)?,
                                                   hold:inout ((Any?) -> Void)?,
                                                   instance: AnyFlowRepresentable,
                                                   instancePosition: Int,
                                                   from: (instance: AnyFlowRepresentable, metadata: FlowRepresentableMetaData)?,
                                                   metadata: FlowRepresentableMetaData,
                                                   onFinish: ((Any?) -> Void)?) {
        viewToPresent = (instance: instance, metadata: metadata)
        self.replaceInstance(atIndex: instancePosition, withInstance: instance)
        let instanceNode = self.instances.first!.traverse(instancePosition)!
        self.setupCallbacks(for: instanceNode, onFinish: onFinish)
        hold = instanceNode.value?.proceedInWorkflowStorage

        self.orchestrationResponder?.proceed(to: (instance: instanceNode, metadata: metadata), from: convertInput(from))

    }
}
