//
//  Workflow.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/26/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation

/**
 A doubly linked list of `FlowRepresentableMetadata`s; used to define a process.

 ### Discussion
 In a sufficiently complex application it may make sense to create a structure to hold onto all the workflows in an application.
 */
/// #### Example
/// ```swift
/// struct Workflows {
///     static let schedulingFlow = Workflow(SomeFlowRepresentable.self)
///         .thenProceed(with: SomeOtherFlowRepresentable.self)
/// }
/// ```
public final class Workflow<F: FlowRepresentable>: LinkedList<_WorkflowItem> {
    public required init(_ node: Element?) {
        super.init(node)
    }

    /// The `OrchestartionResponder` the `Workflow` will send actions to.
    public internal(set) var orchestrationResponder: OrchestrationResponder?

    /// Creates an `Workflow` with a `WorkflowItem` that has metadata, but no instance
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
                                          passedArgs: AnyWorkflow.PassedArgs,
                                          launchStyle: LaunchStyle = .default,
                                          onFinish: ((AnyWorkflow.PassedArgs) -> Void)? = nil) -> Element? {
        removeInstances()
        self.orchestrationResponder = orchestrationResponder
        var root: Element?
        var passedArgs = passedArgs

        let firstLoadedInstance = first?.traverse { [self] nextNode in
            let flowRepresentable = nextNode.value.metadata.flowRepresentableFactory(passedArgs)
            flowRepresentable.workflow = AnyWorkflow(self)
            flowRepresentable.proceedInWorkflowStorage = { passedArgs = $0 }

            let shouldLoad = flowRepresentable.shouldLoad()

            defer {
                let persistence = nextNode.value.metadata.calculatePersistence(passedArgs)
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

    private func setupProceedInWorkflowStorage(node: Element, args: AnyWorkflow.PassedArgs, onFinish: ((AnyWorkflow.PassedArgs) -> Void)?) {
        var argsToPass = args
        var root: Element?
        // traverse AND mutate the above variables
        let nextLoadedNode = node.next?.traverse { nextNode in
            let persistence = nextNode.value.metadata.calculatePersistence(argsToPass)
            let flowRepresentable = nextNode.value.metadata.flowRepresentableFactory(argsToPass)
            flowRepresentable.workflow = AnyWorkflow(self)

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

extension Workflow {
    /**
     A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
     - Parameter type: A reference to the class used to create the workflow
     - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
     - Parameter flowPersistence: An `FlowPersistence`type representing how this item in the workflow should persist.
     - Returns: `Workflow`
     */
    public convenience init(_ type: F.Type,
                            launchStyle: LaunchStyle = .default,
                            flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) {
        self.init(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
    }
    /**
     A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
     - Parameter type: A reference to the class used to create the workflow
     - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
     - Parameter flowPersistence: A closure taking in the generic type from the `FlowRepresentable` and returning a `FlowPersistence`type representing how this item in the workflow should persist.
     - Returns: `Workflow`
     */
    public convenience init(_ type: F.Type,
                            launchStyle: LaunchStyle = .default,
                            flowPersistence: @escaping (F.WorkflowInput) -> FlowPersistence) {
        self.init(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { data in
            guard case.args(let extracted) = data,
                  let cast = extracted as? F.WorkflowInput else { return .default }
            return flowPersistence(cast)
        })
    }

    /**
     A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
     - Parameter type: A reference to the class used to create the workflow
     - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
     - Parameter flowPersistence: A closure returning a `FlowPersistence`type representing how this item in the workflow should persist.
     - Returns: `Workflow`
     */
    public convenience init(_ type: F.Type,
                            launchStyle: LaunchStyle = .default,
                            flowPersistence: @escaping () -> FlowPersistence) where F.WorkflowInput == Never {
        self.init(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
    }

    /**
     A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
     - Parameter type: A reference to the class used to create the workflow
     - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
     - Parameter flowPersistence: A closure returning a `FlowPersistence`type representing how this item in the workflow should persist.
     - Returns: `Workflow`
     */
    public convenience init(_ type: F.Type,
                            launchStyle: LaunchStyle = .default,
                            flowPersistence: @escaping () -> FlowPersistence) where F.WorkflowInput == AnyWorkflow.PassedArgs {
        self.init(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
    }
}

extension Workflow where F.WorkflowOutput == Never {
    /**
     A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
     - Parameter type: A reference to the class used to create the workflow
     - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
     - Parameter flowPersistence: An `FlowPersistence`type representing how this item in the workflow should persist.
     - Returns: `Workflow`
     */
    public func thenProceed<FR: FlowRepresentable>(with type: FR.Type,
                                                   launchStyle: LaunchStyle = .default,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR> where FR.WorkflowInput == Never {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
        return wf
    }

    /**
     A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
     - Parameter type: A reference to the class used to create the workflow
     - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
     - Parameter flowPersistence: An `FlowPersistence`type representing how this item in the workflow should persist.
     - Returns: `Workflow`
     */
    public func thenProceed<FR: FlowRepresentable>(with type: FR.Type,
                                                   launchStyle: LaunchStyle = .default,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR>
    where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
        return wf
    }
}

extension Workflow {
    /**
     A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
     - Parameter type: A reference to the class used to create the workflow
     - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
     - Parameter flowPersistence: An `FlowPersistence`type representing how this item in the workflow should persist.
     - Returns: `Workflow`
     */
    public func thenProceed<FR: FlowRepresentable>(with type: FR.Type,
                                                   launchStyle: LaunchStyle = .default,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR> where F.WorkflowOutput == FR.WorkflowInput {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
        return wf
    }

    /**
     A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
     - Parameter type: A reference to the class used to create the workflow
     - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
     - Parameter flowPersistence: A closure taking in the generic type from the `FlowRepresentable` and returning a `FlowPersistence`type representing how this item in the workflow should persist.
     - Returns: `Workflow`
     */
    public func thenProceed<FR: FlowRepresentable>(with type: FR.Type,
                                                   launchStyle: LaunchStyle = .default,
                                                   flowPersistence: @escaping (FR.WorkflowInput) -> FlowPersistence) -> Workflow<FR> where F.WorkflowOutput == FR.WorkflowInput {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { data in
            guard case.args(let extracted) = data,
                  let cast = extracted as? FR.WorkflowInput else { return .default }
            return flowPersistence(cast)
        })
        return wf
    }

    /**
     A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
     - Parameter type: A reference to the class used to create the workflow
     - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
     - Parameter flowPersistence: A closure returning a `FlowPersistence`type representing how this item in the workflow should persist.
     - Returns: `Workflow`
     */
    public func thenProceed<FR: FlowRepresentable>(with type: FR.Type,
                                                   launchStyle: LaunchStyle = .default,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR> where FR.WorkflowInput == Never {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
        return wf
    }

    /**
     A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
     - Parameter type: A reference to the class used to create the workflow
     - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
     - Parameter flowPersistence: A closure returning a `FlowPersistence`type representing how this item in the workflow should persist.
     - Returns: `Workflow`
     */
    public func thenProceed<FR: FlowRepresentable>(with type: FR.Type,
                                                   launchStyle: LaunchStyle = .default,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR>
    where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
        return wf
    }
}
