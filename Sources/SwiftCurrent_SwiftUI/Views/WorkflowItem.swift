//
//  WorkflowItem.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 7/20/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//
//  swiftlint:disable file_types_order

import SwiftUI
import SwiftCurrent

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
protocol WorkflowModifier {
    func modify(workflow: AnyWorkflow)
}

/**
 A view created by a `WorkflowLauncher`.

 ### Discussion
 You do not instantiate this view directly, rather you call `thenProceed(with:)` on a `WorkflowLauncher`.
 */
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct WorkflowItem<Args, Wrapped: View, Content: View>: View {
    @Binding private var isLaunched: Bool

    let inspection = Inspection<Self>()
    // These need to be state variables to survive SwiftUI re-rendering. Change under penalty of torture BY the codebase you modified.
    @State private var wrapped: Wrapped?
    @State private var launchArgs: AnyWorkflow.PassedArgs
    @State private var onFinish = [(AnyWorkflow.PassedArgs) -> Void]()
    @State private var onAbandon = [() -> Void]()
    @State private var metadata: FlowRepresentableMetadata

    @StateObject private var model: WorkflowViewModel
    @StateObject private var launcher: Launcher

    public var body: some View {
        ConditionalViewWrapper {
            if isLaunched {
                if let body = model.body as? Content {
                    body.onReceive(model.onAbandonPublisher) { onAbandon.forEach { $0() } }
                } else {
                    wrapped
                }
            }
        }
        .onReceive(inspection.notice) { inspection.visit(self, $0) }
        .onReceive(model.onFinishPublisher, perform: _onFinish)
        .onChange(of: isLaunched) { if !$0 { resetWorkflow() } }
    }

    private init<A, W, C, A1, W1, C1>(previous: WorkflowItem<A, W, C>, _ closure: () -> Wrapped) where Wrapped == WorkflowItem<A1, W1, C1> {
        _isLaunched = previous._isLaunched
        let wrapped = closure()
        _wrapped = State(initialValue: wrapped)
        _launchArgs = previous._launchArgs
        _onFinish = previous._onFinish
        _onAbandon = previous._onAbandon
        _model = previous._model
        _launcher = previous._launcher
        _metadata = previous._metadata
    }

    public init(_ item: Content.Type) where Wrapped == Never, Args == Content.WorkflowOutput, Content: FlowRepresentable & View {
        _isLaunched = Binding { false } set: { _ in } // default value, overridden later
        _launchArgs = State(initialValue: .none) // default value, overridden later
        let metadata = FlowRepresentableMetadata(Content.self,
                                                 launchStyle: .new,
                                                 flowPersistence: { _ in .default },
                                                 flowRepresentableFactory: {
                                                    let afrv = AnyFlowRepresentableView(type: Content.self, args: $0)
//                                                        modifierClosure?(afrv)
                                                    return afrv
                                                 })
        _metadata = State(initialValue: metadata)
        // All of this is a lie
        let model = WorkflowViewModel(isLaunched: _isLaunched, launchArgs: .none)
        _model = StateObject(wrappedValue: model)
        _launcher = StateObject(wrappedValue: Launcher(workflow: nil,
                                                       responder: model,
                                                       launchArgs: .none))
    }

    init<A>(_ launcher: WorkflowLauncher<Args>, isLaunched: Binding<Bool>, wrap: WorkflowItem<A, Wrapped, Content>) {
        _isLaunched = isLaunched
        _launchArgs = State(initialValue: launcher.passedArgs)
        _onFinish = State(initialValue: launcher.onFinish)
        _onAbandon = State(initialValue: launcher.onAbandon)
        _metadata = wrap._metadata
        let wf = AnyWorkflow.empty
        wrap.modify(workflow: wf)
        let model = WorkflowViewModel(isLaunched: isLaunched, launchArgs: launcher.passedArgs)
        _model = StateObject(wrappedValue: model)
        _launcher = StateObject(wrappedValue: Launcher(workflow: wf,
                                                       responder: model,
                                                       launchArgs: launcher.passedArgs))
    }

    public func thenProceed<A, W, C>(with closure: @autoclosure () -> WorkflowItem<A, W, C>) -> WorkflowItem<Args, WorkflowItem<A, W, C>, Content> {
        WorkflowItem<Args, WorkflowItem<A, W, C>, Content>(previous: self) {
            closure()
        }
    }

    private init(workflowLauncher: Self, onFinish: [(AnyWorkflow.PassedArgs) -> Void], onAbandon: [() -> Void]) {
        _model = workflowLauncher._model
        _wrapped = workflowLauncher._wrapped
        _onFinish = State(initialValue: onFinish)
        _onAbandon = State(initialValue: onAbandon)
        _launchArgs = workflowLauncher._launchArgs
        _isLaunched = workflowLauncher._isLaunched
        _launcher = workflowLauncher._launcher
        _metadata = workflowLauncher._metadata
    }

    private func resetWorkflow() {
        launcher.onFinishCalled = false
        launcher.workflow?.launch(withOrchestrationResponder: model, passedArgs: launchArgs)
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
        return Self(workflowLauncher: self, onFinish: onFinish, onAbandon: onAbandon)
    }

    /// Adds an action to perform when this `Workflow` has abandoned.
    public func onAbandon(closure: @escaping () -> Void) -> Self {
        var onAbandon = self.onAbandon
        onAbandon.append(closure)
        return Self(workflowLauncher: self, onFinish: onFinish, onAbandon: onAbandon)
    }

    private func ConditionalViewWrapper<V: View>(@ViewBuilder builder: () -> V) -> some View { builder() }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowItem: WorkflowModifier {
    func modify(workflow: AnyWorkflow) {
        workflow.append(metadata)
        (wrapped as? WorkflowModifier)?.modify(workflow: workflow)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
private final class Launcher: ObservableObject {
    var onFinishCalled = false
    var workflow: AnyWorkflow?
    init(workflow: AnyWorkflow?,
         responder: OrchestrationResponder,
         launchArgs: AnyWorkflow.PassedArgs) {
        self.workflow = workflow
        if workflow?.orchestrationResponder == nil {
            workflow?.launch(withOrchestrationResponder: responder, passedArgs: launchArgs)
        }
    }
}

//@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
//extension ModifiedWorkflowView where Args == Never {
//    /**
//     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
//     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
//     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
//     */
//    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Self, T> where FR.WorkflowInput == Never {
//        ModifiedWorkflowView<FR.WorkflowOutput, Self, T>(self, item: item)
//    }
//}
//
//@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
//extension ModifiedWorkflowView where Args == AnyWorkflow.PassedArgs {
//    /**
//     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
//     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
//     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
//     */
//    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Self, T> where FR.WorkflowInput == AnyWorkflow.PassedArgs {
//        ModifiedWorkflowView<FR.WorkflowOutput, Self, T>(self, item: item)
//    }
//
//    /**
//     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
//     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
//     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
//     */
//    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Self, T> where FR.WorkflowInput == Never {
//        ModifiedWorkflowView<FR.WorkflowOutput, Self, T>(self, item: item)
//    }
//
//    /**
//     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
//     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
//     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
//     */
//    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Self, T> {
//        ModifiedWorkflowView<FR.WorkflowOutput, Self, T>(self, item: item)
//    }
//}
//
//@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
//extension ModifiedWorkflowView {
//    /**
//     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
//     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
//     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
//     */
//    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Self, T> where Args == FR.WorkflowInput {
//        ModifiedWorkflowView<FR.WorkflowOutput, Self, T>(self, item: item)
//    }
//
//    /**
//     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
//     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
//     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
//     */
//    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Self, T> where FR.WorkflowInput == AnyWorkflow.PassedArgs {
//        ModifiedWorkflowView<FR.WorkflowOutput, Self, T>(self, item: item)
//    }
//
//    /**
//     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
//     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
//     - Returns: a new `ModifiedWorkflowView` with the additional `FlowRepresentable` item.
//     */
//    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Self, T> where FR.WorkflowInput == Never {
//        ModifiedWorkflowView<FR.WorkflowOutput, Self, T>(self, item: item)
//    }
//}
