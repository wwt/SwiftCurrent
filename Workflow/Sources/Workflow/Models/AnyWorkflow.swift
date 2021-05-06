//
//  AnyWorkflow.swift
//  
//
//  Created by Tyler Thompson on 11/25/20.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation

/// A type erased `Workflow`
public class AnyWorkflow: LinkedList<FlowRepresentableMetadata> {
    /// A `LinkedList.Node` that holds onto the loaded `AnyFlowRepresentable`s.
    public typealias InstanceNode = LinkedList<AnyFlowRepresentable?>.Element
    internal var instances = LinkedList<AnyFlowRepresentable?>()
    internal var orchestrationResponder: OrchestrationResponder?

    /**
     Sets the `OrchestrationResponder` on the workflow.
     - Parameter orchestrationResponder: The `OrchestrationResponder` to notify when the `Workflow` proceeds or backs up.
    */
    public func applyOrchestrationResponder(_ orchestrationResponder: OrchestrationResponder) {
        self.orchestrationResponder = orchestrationResponder
    }

    #warning("Maybe OnFinish should take a AnyWorkflow.PassedArgs")
    /**
     Launches the `Workflow`.
     - Parameter launchStyle: The launch style to use.
     - Parameter onFinish: The closure to call when the last element in the `Workflow` proceeds.
     - Returns: The first loaded instance or nil, if none was loaded.
     */
    @discardableResult public func launch(withLaunchStyle launchStyle: LaunchStyle = .default,
                                          onFinish: ((Any?) -> Void)? = nil) -> InstanceNode? {
        launch(passedArgs: .none, withLaunchStyle: launchStyle, onFinish: onFinish)
    }

    /**
     Launches the `Workflow`.

     ### Discussion
     Args are passed to the first instance, it has the opportunity to load, not load and transform them, or just not load.
     In the event an instance does not load and does not transform args, they are passed unmodified to the next instance in the `Workflow` until one loads.

     - Parameter args: The arguments to pass to the first instance(s).
     - Parameter launchStyle: The launch style to use.
     - Parameter onFinish: The closure to call when the last element in the `Workflow` proceeds.
     - Returns: The first loaded instance or nil, if none was loaded.
     */
    @discardableResult public func launch(with args: Any?,
                                          withLaunchStyle launchStyle: LaunchStyle = .default,
                                          onFinish: ((Any?) -> Void)? = nil) -> InstanceNode? {
        launch(passedArgs: .args(args), withLaunchStyle: launchStyle, onFinish: onFinish)
    }

    /**
     Launches the `Workflow`.

     ### Discussion
     passedArgs are passed to the first instance, it has the opportunity to load, not load and transform them, or just not load.
     In the event an instance does not load and does not transform args, they are passed unmodified to the next instance in the `Workflow` until one loads.

     - Parameter passedArgs: The arguments to pass to the first instance(s).
     - Parameter launchStyle: The launch style to use.
     - Parameter onFinish: The closure to call when the last element in the `Workflow` proceeds.
     - Returns: The first loaded instance or nil, if none was loaded.
     */
    @discardableResult public func launch(passedArgs: PassedArgs,
                                          withLaunchStyle launchStyle: LaunchStyle = .default,
                                          onFinish: ((Any?) -> Void)? = nil) -> InstanceNode? {
        var firstLoadedInstance: InstanceNode?
        removeInstances()
        instances = LinkedList(map { _ in nil })
        var root: (instance: AnyFlowRepresentable, metadata: FlowRepresentableMetadata)?
        var passedArgs = passedArgs

        let metadata = first?.traverse { [self] nextNode in
            let nextMetadata = nextNode.value
            let flowRepresentable = nextMetadata.flowRepresentableFactory(passedArgs)
            flowRepresentable.workflow = self
            flowRepresentable.proceedInWorkflowStorage = { passedArgs = $0 }

            let shouldLoad = flowRepresentable.shouldLoad()

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
            if case .args(let argsToPass) = passedArgs { onFinish?(argsToPass) }
            return nil
        }

        orchestrationResponder?.launchOrProceed(to: (instance: first, metadata:m), from: convertInput(root))

        return firstLoadedInstance
    }

    #warning("Remove animated, cuz bad")
    /**
    Called when the workflow should be terminated, and the app should return to the point before the workflow was launched
    - Parameter animated: A boolean indicating whether abandoning the workflow should be animated
    - Parameter onFinish: A callback after the workflow has been abandoned.
    - Note: In order for this to function the workflow must have a presenter, presenters must call back to the workflow to inform when the abandon process has finished for the onFinish callback to be called.
    */
    public func abandon(animated: Bool = true, onFinish:(() -> Void)? = nil) {
        orchestrationResponder?.abandon(self, animated: animated) { [self] in
            removeInstances()
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
                let flowRepresentable = metadata.flowRepresentableFactory(argsToPass)
                flowRepresentable.workflow = self

                flowRepresentable.proceedInWorkflowStorage = { argsToPass = $0 }

                let shouldLoad = flowRepresentable.shouldLoad()
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

    private func setupBackUpCallbacks(_ node: LinkedList<AnyFlowRepresentable?>.Element, _ onFinish: ((Any?) -> Void)?) {
        guard let currentMetadataNode = first?.traverse(node.position) else {
            fatalError("Internal state of workflow completely mangled during configuration of proceed backward callbacks.")
        }
        node.value?.backUpInWorkflowStorage = { [self] in
            let previousLoadedNode = node.traverse(direction: .backward) { previousNode in
                previousNode.value != nil
            }

            guard let previousNode = previousLoadedNode else { throw WorkflowError.failedToBackUp }

            guard let previousMetadataNode = first?.traverse(previousNode.position) else {
                fatalError("Internal state of workflow completely mangled during execution of proceed backward callback.")
            }

            orchestrationResponder?.backUp(from: (instance: node, metadata: currentMetadataNode.value), to: (instance: previousNode, metadata: previousMetadataNode.value))
        }
    }

    private func setupCallbacks(for node: LinkedList<AnyFlowRepresentable?>.Element, onFinish: ((Any?) -> Void)?) {
        setupProceedCallbacks(node, onFinish)
        setupBackUpCallbacks(node, onFinish)
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
    /// A type that represents either a type erased value or no value.
    public enum PassedArgs {
        /// No arguments are passed forward.
        case none
        /// The type erased value passed forward.
        case args(Any?)

        /**
         Performs a coalescing operation, returning the type erased value of a `PassedArgs` instance or a default value.

         - Parameter defaultValue: the default value to use if there are no args.
         - Returns: type erased value of a `PassedArgs` instance or a default value.
         */
        public func extract(_ defaultValue: Any?) -> Any? {
            if case .args(let value) = self {
                return value
            }
            return defaultValue
        }
    }
}
