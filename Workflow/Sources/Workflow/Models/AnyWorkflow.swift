//
//  AnyWorkflow.swift
//  Workflow
//
//  Created by Tyler Thompson on 11/25/20.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation

#warning("Consider: This does not use our recommended approach to type erasure, should we change it?")
/// A type erased `Workflow`
public class AnyWorkflow: LinkedList<_WorkflowItem> {
    /// The `OrchestrationResponder` the `Workflow` will send actions to.
    public internal(set) var orchestrationResponder: OrchestrationResponder?

    /// Creates an `AnyWorkflow` with a `WorkflowItem` that has metadata, but no instance
    public convenience init(_ metadata: FlowRepresentableMetadata) {
        self.init(Node(with: _WorkflowItem(metadata: metadata, instance: nil)))
    }

    /// Appends a `WorkflowItem` that has metadata, but no instance
    public func append(_ metadata: FlowRepresentableMetadata) {
        append(_WorkflowItem(metadata: metadata, instance: nil))
    }

    /**
     Launches the `Workflow`.
     - Parameter orchestrationResponder: The `OrchestrationResponder` to notify when the `Workflow` proceeds or backs up.
     - Parameter launchStyle: The launch style to use.
     - Parameter onFinish: The closure to call when the last element in the workflow proceeds; called with the `AnyWorkflow.PassedArgs` the workflow finished with.
     - Returns: The first loaded instance or nil, if none was loaded.
     */
    @discardableResult public func launch(withOrchestrationResponder orchestrationResponder: OrchestrationResponder,
                                          launchStyle: LaunchStyle = .default,
                                          onFinish: ((AnyWorkflow.PassedArgs) -> Void)? = nil) -> Element? {
        launch(withOrchestrationResponder: orchestrationResponder,
               passedArgs: .none,
               launchStyle: launchStyle,
               onFinish: onFinish)
    }

    /**
     Launches the `Workflow`.

     ### Discussion
     Args are passed to the first instance, it has the opportunity to load, not load and transform them, or just not load.
     In the event an instance does not load and does not transform args, they are passed unmodified to the next instance in the `Workflow` until one loads.

     - Parameter orchestrationResponder: The `OrchestrationResponder` to notify when the `Workflow` proceeds or backs up.
     - Parameter args: The arguments to pass to the first instance(s).
     - Parameter launchStyle: The launch style to use.
     - Parameter onFinish: The closure to call when the last element in the workflow proceeds; called with the `AnyWorkflow.PassedArgs` the workflow finished with.
     - Returns: The first loaded instance or nil, if none was loaded.
     */
    @discardableResult public func launch(withOrchestrationResponder orchestrationResponder: OrchestrationResponder,
                                          args: Any?,
                                          withLaunchStyle launchStyle: LaunchStyle = .default,
                                          onFinish: ((AnyWorkflow.PassedArgs) -> Void)? = nil) -> Element? {
        launch(withOrchestrationResponder: orchestrationResponder,
               passedArgs: .args(args),
               launchStyle: launchStyle,
               onFinish: onFinish)
    }

    /**
     Launches the `Workflow`.

     ### Discussion
     passedArgs are passed to the first instance, it has the opportunity to load, not load and transform them, or just not load.
     In the event an instance does not load and does not transform args, they are passed unmodified to the next instance in the `Workflow` until one loads.

     - Parameter orchestrationResponder: The `OrchestrationResponder` to notify when the `Workflow` proceeds or backs up.
     - Parameter passedArgs: The arguments to pass to the first instance(s).
     - Parameter launchStyle: The launch style to use.
     - Parameter onFinish: The closure to call when the last element in the workflow proceeds; called with the `AnyWorkflow.PassedArgs` the workflow finished with.
     - Returns: The first loaded instance or nil, if none was loaded.
     */
    @discardableResult public func launch(withOrchestrationResponder orchestrationResponder: OrchestrationResponder,
                                          passedArgs: PassedArgs,
                                          launchStyle: LaunchStyle = .default,
                                          onFinish: ((AnyWorkflow.PassedArgs) -> Void)? = nil) -> Element? {
        removeInstances()
        self.orchestrationResponder = orchestrationResponder
        var root: Element?
        var passedArgs = passedArgs

        let firstLoadedInstance = first?.traverse { [self] nextNode in
            let flowRepresentable = nextNode.value.metadata.flowRepresentableFactory(passedArgs)
            flowRepresentable.workflow = self
            flowRepresentable.proceedInWorkflowStorage = { passedArgs = $0 }

            let shouldLoad = flowRepresentable.shouldLoad()

            defer {
                let persistence = nextNode.value.metadata.setPersistence(passedArgs)
                if shouldLoad {
                    nextNode.value.instance = flowRepresentable
                    setupCallbacks(for: nextNode, onFinish: onFinish)
                } else if !shouldLoad && persistence == .persistWhenSkipped {
                    nextNode.value.instance = flowRepresentable
                    setupCallbacks(for: nextNode, onFinish: onFinish)
                    orchestrationResponder.launchOrProceed(to: nextNode, from: root)
                    root = nextNode
                }
            }
            return shouldLoad
        }

        guard let first = firstLoadedInstance  else {
            onFinish?(passedArgs)
            return nil
        }

        orchestrationResponder.launchOrProceed(to: first, from: root)

        return firstLoadedInstance
    }

    public func _abandon() {
        removeInstances()
        orchestrationResponder = nil
    }

    deinit {
        removeInstances()
        orchestrationResponder = nil
    }

    private func removeInstances() {
        forEach { node in
            node.value.instance?.proceedInWorkflowStorage = nil
            node.value.instance = nil
        }
    }

    private func setupProceedCallbacks(_ node: Element, _ onFinish: ((AnyWorkflow.PassedArgs) -> Void)?) {
        node.value.instance?.proceedInWorkflowStorage = { [weak self] args in
            guard let self = self else { return }
            self.setupProceedInWorkflowStorage(node: node,
                                               args: args,
                                               onFinish: onFinish)
        }
    }

    private func setupProceedInWorkflowStorage(node: Element, args: PassedArgs, onFinish: ((AnyWorkflow.PassedArgs) -> Void)?) {
        var argsToPass = args
        var root: Element?
        // traverse AND mutate the above variables
        let nextLoadedNode = node.next?.traverse { nextNode in
            let persistence = nextNode.value.metadata.setPersistence(argsToPass)
            let flowRepresentable = nextNode.value.metadata.flowRepresentableFactory(argsToPass)
            flowRepresentable.workflow = self

            // Capture new arguments, if shouldLoad calls proceedInWorkflow
            flowRepresentable.proceedInWorkflowStorage = { argsToPass = $0 }

            let shouldLoad = flowRepresentable.shouldLoad()
            nextNode.value.instance = (shouldLoad || (!shouldLoad && persistence == .persistWhenSkipped)) ? flowRepresentable : nil

            if !shouldLoad && persistence == .persistWhenSkipped {
                nextNode.value.instance = flowRepresentable
                setupCallbacks(for: nextNode, onFinish: onFinish)
                orchestrationResponder?.proceed(to: nextNode, from: root ?? node)
                root = nextNode
            }

            return shouldLoad
        }

        defer {
            if node.value.metadata.persistence == .removedAfterProceeding {
                node.value.instance?.proceedInWorkflowStorage = nil
                node.value.instance = nil
            }
        }

        guard let nextNode = nextLoadedNode else {
            onFinish?(argsToPass)
            return
        }

        setupCallbacks(for: nextNode, onFinish: onFinish)
        orchestrationResponder?.proceed(to: nextNode, from: root ?? node)
    }

    private func setupBackUpCallbacks(_ node: Element, _ onFinish: ((AnyWorkflow.PassedArgs) -> Void)?) {
        node.value.instance?.backUpInWorkflowStorage = { [self] in
            let previousLoadedNode = node.traverse(direction: .backward) { previousNode in
                previousNode.value.instance != nil
            }

            guard let previousNode = previousLoadedNode else { throw WorkflowError.failedToBackUp }

            orchestrationResponder?.backUp(from: node, to: previousNode)
        }
    }

    private func setupCallbacks(for node: Element, onFinish: ((AnyWorkflow.PassedArgs) -> Void)?) {
        setupProceedCallbacks(node, onFinish)
        setupBackUpCallbacks(node, onFinish)
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
        public func extractArgs(defaultValue: Any?) -> Any? {
            if case .args(let value) = self {
                return value
            }
            return defaultValue
        }
    }
}
