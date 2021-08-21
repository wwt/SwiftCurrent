//
//  WorkflowLauncher.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 7/12/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//
//  swiftlint:disable file_types_order

import SwiftUI
import SwiftCurrent

/**
 Used to build a `Workflow` in SwiftUI; call thenProceed to create a SwiftUI view.

 ### Discussion
 The preferred method for creating a `Workflow` with SwiftUI is a combination of `WorkflowLauncher` and `WorkflowItem`. Initialize with arguments if your first `FlowRepresentable` has an input type.

 #### Example
 */
/// ```swift
/// WorkflowLauncher(isLaunched: $isLaunched.animation(), args: "String in")
///     .thenProceed(with: WorkflowItem(FirstView.self)
///                     .applyModifiers {
///         if true { // Enabling transition animation
///             $0.background(Color.gray)
///                 .transition(.slide)
///                 .animation(.spring())
///         }
///     })
///     .thenProceed(with: WorkflowItem(SecondView.self)
///                     .persistence(.removedAfterProceeding)
///                     .applyModifiers {
///         if true {
///             $0.SecondViewSpecificModifier()
///                 .padding(10)
///                 .background(Color.purple)
///                 .transition(.opacity)
///                 .animation(.easeInOut)
///         }
///     })
///     .onAbandon { print("isLaunched is now false") }
///     .onFinish { args in print("Finished 1: \(args)") }
///     .onFinish { print("Finished 2: \($0)") }
///     .background(Color.green)
///  ```
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct WorkflowLauncher<Args> {
    @Binding private var isLaunched: Bool
    var passedArgs = AnyWorkflow.PassedArgs.none
    var onFinish = [(AnyWorkflow.PassedArgs) -> Void]()
    var onAbandon = [() -> Void]()

    /**
     Creates a base for proceeding with a `WorkflowItem`.
     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
     */
    public init(isLaunched: Binding<Bool>) where Args == Never {
        _isLaunched = isLaunched
    }

    /**
     Creates a base for proceeding with a `WorkflowItem`.
     - Parameter isLaunched: binding that controls launching the underlying `Workflow`.
     - Parameter startingArgs: arguments passed to the first `FlowRepresentable` in the underlying `Workflow`.
     */
    public init(isLaunched: Binding<Bool>, startingArgs args: Args) {
        _isLaunched = isLaunched
        if let args = args as? AnyWorkflow.PassedArgs {
            passedArgs = args
        } else {
            passedArgs = .args(args)
        }
    }

    private init(isLaunched: Binding<Bool>,
                 startingArgs: AnyWorkflow.PassedArgs,
                 onFinish: [(AnyWorkflow.PassedArgs) -> Void],
                 onAbandon: [() -> Void]) {
        _isLaunched = isLaunched
        passedArgs = startingArgs
        self.onFinish = onFinish
        self.onAbandon = onAbandon
    }

    /// Adds an action to perform when this `Workflow` has finished.
    public func onFinish(closure: @escaping (AnyWorkflow.PassedArgs) -> Void) -> Self {
        var onFinish = self.onFinish
        onFinish.append(closure)
        return Self(isLaunched: _isLaunched,
                    startingArgs: passedArgs,
                    onFinish: onFinish,
                    onAbandon: onAbandon)
    }

    /// Adds an action to perform when this `Workflow` has abandoned.
    public func onAbandon(closure: @escaping () -> Void) -> Self {
        var onAbandon = self.onAbandon
        onAbandon.append(closure)
        return Self(isLaunched: _isLaunched,
                    startingArgs: passedArgs,
                    onFinish: onFinish,
                    onAbandon: onAbandon)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct WorkflowLauncherView<Content: View>: View {
    @State private var content: Content
    @StateObject private var model: WorkflowViewModel
    @StateObject private var launcher: Launcher
    @State private var onFinish = [(AnyWorkflow.PassedArgs) -> Void]()
    @State private var onAbandon = [() -> Void]()

    let inspection = Inspection<Self>()

    public var body: some View {
        content
            .environmentObject(model)
            .environmentObject(launcher)
            .onReceive(model.onFinishPublisher, perform: _onFinish)
            .onReceive(model.onAbandonPublisher) { onAbandon.forEach { $0() } }
            .onReceive(inspection.notice) { inspection.visit(self, $0) }
    }

    init(item: Content,
         workflow: AnyWorkflow,
         isLaunched: Binding<Bool>,
         launchArgs: AnyWorkflow.PassedArgs,
         onFinish: [(AnyWorkflow.PassedArgs) -> Void],
         onAbandon: [() -> Void]) {
        let model = WorkflowViewModel(isLaunched: isLaunched, launchArgs: launchArgs)
        _model = StateObject(wrappedValue: model)
        _launcher = StateObject(wrappedValue: Launcher(workflow: workflow,
                                                       responder: model,
                                                       launchArgs: launchArgs))
        _content = State(wrappedValue: item)
        _onFinish = State(initialValue: onFinish)
        _onAbandon = State(initialValue: onAbandon)
    }

    private init(current: Self, onFinish: [(AnyWorkflow.PassedArgs) -> Void], onAbandon: [() -> Void]) {
        _model = current._model
        _launcher = current._launcher
        _content = current._content
        _onFinish = State(initialValue: onFinish)
        _onAbandon = State(initialValue: onAbandon)
    }

    private func _onFinish(_ args: AnyWorkflow.PassedArgs?) {
        guard let args = args, !launcher.onFinishCalled else { return }
        launcher.onFinishCalled = true
        onFinish.forEach { $0(args) }
    }

    /// Adds an action to perform when this `Workflow` has finished.
    public func onFinish(closure: @escaping (AnyWorkflow.PassedArgs) -> Void) -> Self {
        var onFinish = self.onFinish
        onFinish.append(closure)
        return Self(current: self, onFinish: onFinish, onAbandon: onAbandon)
    }

    /// Adds an action to perform when this `Workflow` has abandoned.
    public func onAbandon(closure: @escaping () -> Void) -> Self {
        var onAbandon = self.onAbandon
        onAbandon.append(closure)
        return Self(current: self, onFinish: onFinish, onAbandon: onAbandon)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowLauncher where Args == Never {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, W, C>(with closure: @autoclosure () -> WorkflowItem<FR, W, C>) -> WorkflowLauncherView<WorkflowItem<FR, W, C>> where FR.WorkflowInput == Never {
        let item = WorkflowItem(self, isLaunched: _isLaunched, wrap: closure())
        let wf = AnyWorkflow.empty
        item.modify(workflow: wf)
        return WorkflowLauncherView(item: item,
                                    workflow: wf,
                                    isLaunched: _isLaunched,
                                    launchArgs: passedArgs,
                                    onFinish: onFinish,
                                    onAbandon: onAbandon)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowLauncher where Args == AnyWorkflow.PassedArgs {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, W, C>(with closure: @autoclosure () -> WorkflowItem<FR, W, C>) -> WorkflowLauncherView<WorkflowItem<FR, W, C>> {
        let item = WorkflowItem(self, isLaunched: _isLaunched, wrap: closure())
        let wf = AnyWorkflow.empty
        item.modify(workflow: wf)
        return WorkflowLauncherView(item: item,
                                    workflow: wf,
                                    isLaunched: _isLaunched,
                                    launchArgs: passedArgs,
                                    onFinish: onFinish,
                                    onAbandon: onAbandon)
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, W, C>(with closure: @autoclosure () -> WorkflowItem<FR, W, C>) -> WorkflowLauncherView<WorkflowItem<FR, W, C>> where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        let item = WorkflowItem(self, isLaunched: _isLaunched, wrap: closure())
        let wf = AnyWorkflow.empty
        item.modify(workflow: wf)
        return WorkflowLauncherView(item: item,
                                    workflow: wf,
                                    isLaunched: _isLaunched,
                                    launchArgs: passedArgs,
                                    onFinish: onFinish,
                                    onAbandon: onAbandon)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowLauncher {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, W, C>(with closure: @autoclosure () -> WorkflowItem<FR, W, C>) -> WorkflowLauncherView<WorkflowItem<FR, W, C>> {
        let item = WorkflowItem(self, isLaunched: _isLaunched, wrap: closure())
        let wf = AnyWorkflow.empty
        item.modify(workflow: wf)
        return WorkflowLauncherView(item: item,
                                    workflow: wf,
                                    isLaunched: _isLaunched,
                                    launchArgs: passedArgs,
                                    onFinish: onFinish,
                                    onAbandon: onAbandon)
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, W, C>(with closure: @autoclosure () -> WorkflowItem<FR, W, C>) -> WorkflowLauncherView<WorkflowItem<FR, W, C>> where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        let item = WorkflowItem(self, isLaunched: _isLaunched, wrap: closure())
        let wf = AnyWorkflow.empty
        item.modify(workflow: wf)
        return WorkflowLauncherView(item: item,
                                    workflow: wf,
                                    isLaunched: _isLaunched,
                                    launchArgs: passedArgs,
                                    onFinish: onFinish,
                                    onAbandon: onAbandon)
    }
}
