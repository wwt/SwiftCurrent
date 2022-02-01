//
//  Workflow.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/26/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//
//  swiftlint:disable file_length

import Foundation

/**
 A doubly linked list of `FlowRepresentableMetadata`s; used to define a process.

 ### Discussion
 In a sufficiently complex application, it may make sense to create a structure to hold onto all the workflows in an application.

 #### Example
 ```swift
 struct Workflows {
     static let schedulingFlow = Workflow(SomeFlowRepresentable.self)
         .thenProceed(with: SomeOtherFlowRepresentable.self)
 }
 ```
 */
public final class Workflow<F: FlowRepresentable>: LinkedList<_WorkflowItem> {
    public required init(_ node: Element?) {
        super.init(node)
    }

    public required init(withoutCopying node: Element? = nil) {
        super.init(withoutCopying: node)
    }

    /// The `OrchestartionResponder` the `Workflow` will send actions to.
    public internal(set) var orchestrationResponder: OrchestrationResponder?

    /// Creates a `Workflow` with a `WorkflowItem` that has metadata, but no instance.
    public convenience init(_ metadata: FlowRepresentableMetadata) {
        self.init(Node(with: _WorkflowItem(metadata: metadata, instance: nil)))
    }

    /// Appends a `WorkflowItem` that has metadata, but no instance.
    public func append(_ metadata: FlowRepresentableMetadata) {
        append(_WorkflowItem(metadata: metadata, instance: nil))
    }

    /**
     Launches the `Workflow`.
     - Parameter orchestrationResponder: the `OrchestrationResponder` to notify when the `Workflow` proceeds or backs up.
     - Parameter launchStyle: the launch style to use.
     - Parameter onFinish: the closure to call when the last element in the workflow proceeds; called with the `AnyWorkflow.PassedArgs` the workflow finished with.
     - Returns: the first loaded instance or nil, if none was loaded.
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

     - Parameter orchestrationResponder: the `OrchestrationResponder` to notify when the `Workflow` proceeds or backs up.
     - Parameter args: the arguments to pass to the first instance(s).
     - Parameter launchStyle: the launch style to use.
     - Parameter onFinish: the closure to call when the last element in the workflow proceeds; called with the `AnyWorkflow.PassedArgs` the workflow finished with.
     - Returns: the first loaded instance or nil, if none was loaded.
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

     - Parameter orchestrationResponder: the `OrchestrationResponder` to notify when the `Workflow` proceeds or backs up.
     - Parameter passedArgs: the arguments to pass to the first instance(s).
     - Parameter launchStyle: the launch style to use.
     - Parameter onFinish: the closure to call when the last element in the workflow proceeds; called with the `AnyWorkflow.PassedArgs` the workflow finished with.
     - Returns: the first loaded instance or nil, if none was loaded.
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
            orchestrationResponder.complete(AnyWorkflow(self), passedArgs: passedArgs, onFinish: onFinish)
            return nil
        }

        orchestrationResponder.launchOrProceed(to: first, from: root)

        EventReceiver.workflowLaunched(workflow: AnyWorkflow(self),
                                       responder: orchestrationResponder,
                                       args: passedArgs,
                                       style: launchStyle,
                                       onFinish: onFinish)

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
            let persistence = nextNode.value.metadata.setPersistence(argsToPass)
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

        defer {
            if node.value.metadata.persistence == .removedAfterProceeding {
                node.value.instance?.proceedInWorkflowStorage = nil
                node.value.instance = nil
            }
        }

        guard let nextNode = nextLoadedNode else {
            orchestrationResponder?.complete(AnyWorkflow(self), passedArgs: argsToPass, onFinish: onFinish)
            return
        }

        setupCallbacks(for: nextNode, onFinish: onFinish)
        orchestrationResponder?.proceed(to: nextNode, from: root ?? node)
    }

    private func setupBackUpCallbacks(_ node: Element, _ onFinish: ((AnyWorkflow.PassedArgs) -> Void)?) {
        node.value.instance?.backUpInWorkflowStorage = { [self] in
            guard let previousNode = node.previouslyLoadedElement else { throw WorkflowError.failedToBackUp }

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
     Creates a `Workflow` with a `FlowRepresentable`.
     - Parameter type: a reference to the first `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a `FlowPersistence` representing how this item in the workflow should persist.
     */
    public convenience init(_ type: F.Type,
                            launchStyle: LaunchStyle = .default,
                            flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) {
        self.init(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
    }

    /**
     Creates a `Workflow` with a `FlowRepresentable`.
     - Parameter type: a reference to the first `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a closure taking in the generic type from the `FlowRepresentable` and returning a `FlowPersistence` representing how this item in the workflow should persist.
     */
    public convenience init(_ type: F.Type,
                            launchStyle: LaunchStyle = .default,
                            flowPersistence: @escaping (F.WorkflowInput) -> FlowPersistence) {
        self.init(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { data in
            guard case .args(let extracted) = data,
                  let cast = extracted as? F.WorkflowInput else { return .default }
            return flowPersistence(cast)
        })
    }

    /**
     Creates a `Workflow` with a `FlowRepresentable`.
     - Parameter type: a reference to the first `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a closure returning a `FlowPersistence` representing how this item in the workflow should persist.
     */
    public convenience init(_ type: F.Type,
                            launchStyle: LaunchStyle = .default,
                            flowPersistence: @escaping () -> FlowPersistence) where F.WorkflowInput == Never {
        self.init(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
    }

    /**
     Creates a `Workflow` with a `FlowRepresentable`.
     - Parameter type: a reference to the first `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a closure returning a `FlowPersistence` representing how this item in the workflow should persist.
     */
    public convenience init(_ type: F.Type,
                            launchStyle: LaunchStyle = .default,
                            flowPersistence: @escaping (F.WorkflowInput) -> FlowPersistence) where F.WorkflowInput == AnyWorkflow.PassedArgs {
        self.init(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { flowPersistence($0) })
    }
}

extension Workflow where F.WorkflowOutput == Never {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
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
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable>(with type: FR.Type,
                                                   launchStyle: LaunchStyle = .default,
                                                   flowPersistence: @escaping () -> FlowPersistence) -> Workflow<FR> where FR.WorkflowInput == Never {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
        return wf
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable>(with type: FR.Type,
                                                   launchStyle: LaunchStyle = .default,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR> where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
        return wf
    }
}

extension Workflow where F.WorkflowOutput == AnyWorkflow.PassedArgs {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable>(with type: FR.Type,
                                                   launchStyle: LaunchStyle = .default,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR> {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
        return wf
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a closure taking in the generic type from the `FlowRepresentable.WorkflowInput` and returning a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable>(with type: FR.Type,
                                                   launchStyle: LaunchStyle = .default,
                                                   flowPersistence: @escaping (FR.WorkflowInput) -> FlowPersistence) -> Workflow<FR> {
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
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a closure taking in the generic type from the `FlowRepresentable.WorkflowInput` and returning a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable>(with type: FR.Type,
                                                   launchStyle: LaunchStyle = .default,
                                                   flowPersistence: @escaping (FR.WorkflowInput) -> FlowPersistence) -> Workflow<FR> where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { flowPersistence($0) })
        return wf
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a closure taking in the generic type from the `FlowRepresentable.WorkflowInput` and returning a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable>(with type: FR.Type,
                                                   launchStyle: LaunchStyle = .default,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR> where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
        return wf
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a closure returning a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
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
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a closure returning a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable>(with type: FR.Type,
                                                   launchStyle: LaunchStyle = .default,
                                                   flowPersistence: @escaping () -> FlowPersistence) -> Workflow<FR> where FR.WorkflowInput == Never {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
        return wf
    }
}

extension Workflow {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
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
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a closure taking in the generic type from the `FlowRepresentable.WorkflowInput` and returning a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
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
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a closure returning a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
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
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a closure returning a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable>(with type: FR.Type,
                                                   launchStyle: LaunchStyle = .default,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR> where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
        return wf
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a closure returning a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable>(with type: FR.Type,
                                                   launchStyle: LaunchStyle = .default,
                                                   flowPersistence: @escaping (FR.WorkflowInput) -> FlowPersistence) -> Workflow<FR> where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { flowPersistence($0) })
        return wf
    }
}

extension Workflow {
    /**
     Wraps this workflow with a type eraser.
     - Returns: an ``AnyWorkflow`` wrapping this ``Workflow``
     */
    public func eraseToAnyWorkflow() -> AnyWorkflow {
        AnyWorkflow(self)
    }
}
