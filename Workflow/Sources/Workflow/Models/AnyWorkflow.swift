//
//  AnyWorkflow.swift
//  
//
//  Created by Tyler Thompson on 11/25/20.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation

public class WorkflowItem {
    public let metadata: FlowRepresentableMetadata
    public internal(set) var instance: AnyFlowRepresentable?

    init(metadata: FlowRepresentableMetadata, instance: AnyFlowRepresentable? = nil) {
        self.metadata = metadata
        self.instance = instance
    }
}

#warning("Consider: This does not use our recommended approach to type erasure, should we change it?")
/// A type erased `Workflow`
public class AnyWorkflow: LinkedList<WorkflowItem> {
    /// A `LinkedList.Node` that holds onto the loaded `AnyFlowRepresentable`s.
    public private(set) var orchestrationResponder: OrchestrationResponder?

    /**
     Sets the `OrchestrationResponder` on the workflow.
     - Parameter orchestrationResponder: The `OrchestrationResponder` to notify when the `Workflow` proceeds or backs up.
    */
    public func applyOrchestrationResponder(_ orchestrationResponder: OrchestrationResponder) {
        self.orchestrationResponder = orchestrationResponder
    }

    /**
     Launches the `Workflow`.
     - Parameter launchStyle: The launch style to use.
     - Parameter onFinish: The closure to call when the last element in the workflow proceeds; called with the `AnyWorkflow.PassedArgs` the workflow finished with.
     - Returns: The first loaded instance or nil, if none was loaded.
     */
    @discardableResult public func launch(withLaunchStyle launchStyle: LaunchStyle = .default,
                                          onFinish: ((AnyWorkflow.PassedArgs) -> Void)? = nil) -> Element? {
        launch(passedArgs: .none, withLaunchStyle: launchStyle, onFinish: onFinish)
    }

    /**
     Launches the `Workflow`.

     ### Discussion
     Args are passed to the first instance, it has the opportunity to load, not load and transform them, or just not load.
     In the event an instance does not load and does not transform args, they are passed unmodified to the next instance in the `Workflow` until one loads.

     - Parameter args: The arguments to pass to the first instance(s).
     - Parameter launchStyle: The launch style to use.
     - Parameter onFinish: The closure to call when the last element in the workflow proceeds; called with the `AnyWorkflow.PassedArgs` the workflow finished with.
     - Returns: The first loaded instance or nil, if none was loaded.
     */
    @discardableResult public func launch(with args: Any?,
                                          withLaunchStyle launchStyle: LaunchStyle = .default,
                                          onFinish: ((AnyWorkflow.PassedArgs) -> Void)? = nil) -> Element? {
        launch(passedArgs: .args(args), withLaunchStyle: launchStyle, onFinish: onFinish)
    }

    /**
     Launches the `Workflow`.

     ### Discussion
     passedArgs are passed to the first instance, it has the opportunity to load, not load and transform them, or just not load.
     In the event an instance does not load and does not transform args, they are passed unmodified to the next instance in the `Workflow` until one loads.

     - Parameter passedArgs: The arguments to pass to the first instance(s).
     - Parameter launchStyle: The launch style to use.
     - Parameter onFinish: The closure to call when the last element in the workflow proceeds; called with the `AnyWorkflow.PassedArgs` the workflow finished with.
     - Returns: The first loaded instance or nil, if none was loaded.
     */
    @discardableResult public func launch(passedArgs: PassedArgs,
                                          withLaunchStyle launchStyle: LaunchStyle = .default,
                                          onFinish: ((AnyWorkflow.PassedArgs) -> Void)? = nil) -> Element? {
        removeInstances()
        var root: Element?
        var passedArgs = passedArgs

        let firstLoadedInstance = first?.traverse { [self] nextNode in
            let nextMetadata = nextNode.value.metadata
            let flowRepresentable = nextMetadata.flowRepresentableFactory(passedArgs)
            flowRepresentable.workflow = self
            flowRepresentable.proceedInWorkflowStorage = { passedArgs = $0 }

            let shouldLoad = flowRepresentable.shouldLoad()

            defer {
                let persistence = nextMetadata.calculatePersistence(passedArgs)
                if shouldLoad {
                    nextNode.value.instance = flowRepresentable
                    setupCallbacks(for: nextNode, onFinish: onFinish)
                } else if !shouldLoad && persistence == .persistWhenSkipped {
                    nextNode.value.instance = flowRepresentable
                    setupCallbacks(for: nextNode, onFinish: onFinish)
                    orchestrationResponder?.launchOrProceed(to: nextNode, from: root)
                    root = nextNode
                }
            }
            return shouldLoad
        }

        guard let first = firstLoadedInstance  else {
            onFinish?(passedArgs)
            return nil
        }

        orchestrationResponder?.launchOrProceed(to: first, from: root)

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
        node.value.instance?.proceedInWorkflowStorage = { [self] args in
            var argsToPass = args
            var root: Element?
            let nextLoadedNode = node.next?.traverse { nextNode in
                let persistence = nextNode.value.metadata.calculatePersistence(argsToPass)
                let flowRepresentable = nextNode.value.metadata.flowRepresentableFactory(argsToPass)
                flowRepresentable.workflow = self

                flowRepresentable.proceedInWorkflowStorage = { argsToPass = $0 }

                let shouldLoad = flowRepresentable.shouldLoad()
                nextNode.value.instance = (shouldLoad || (!shouldLoad && persistence == .persistWhenSkipped)) ? flowRepresentable : nil

                if !shouldLoad && persistence == .persistWhenSkipped {
                    nextNode.value.instance = flowRepresentable
                    root = nextNode // This needs to be moved UNDER proceed most likely
                    setupCallbacks(for: nextNode, onFinish: onFinish)
                    #warning("""
                        Should from be root ?? node? We should write a test that starts with a loading representable
                        Then has 2 in a row that proceed and skip AND persist while skipped
                        Visualization: FR1 (loads), FR2 (skips, persists), FR3 (skips, persists), FR4 (loads)
                        CORRECT:
                        FR1 calls proceed, this callback tells the reponder to proceed to FR2 from FR1 THEN
                        FR2 calls proceed, this callback tells the responder to proceed from FR2 to FR3 THEN
                        FR3 calls proceed, this callback tells the responder to proceed from FR3 to FR4

                        POSSIBLY HAPPENING NOW (incorrect):
                        FR1 calls proceed, this callback tells the reponder to proceed to FR2 from FR1 THEN
                        FR2 calls proceed, this callback tells the responder to proceed from FR1 to FR3 THEN
                        FR3 calls proceed, this callback tells the responder to proceed from FR1 to FR4
                    """)
                    orchestrationResponder?.proceed(to: nextNode, from: node)
                }

                return shouldLoad
            }

            guard let nextNode = nextLoadedNode else {
                onFinish?(argsToPass)
                return
            }

            setupCallbacks(for: nextNode, onFinish: onFinish)
            orchestrationResponder?.proceed(to: nextNode,
                                            from: root ?? node)
        }
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
