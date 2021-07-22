//
//  ModifiedWorkflowView.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 7/20/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//
//  swiftlint:disable file_types_order

import SwiftUI
import SwiftCurrent

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct ModifiedWorkflowView<Args, Wrapped: View, Content: View>: View {
    @Binding private var isLaunched: Bool

    let inspection = Inspection<Self>()
    private let wrapped: Wrapped?
    private let workflow: AnyWorkflow
    private let launchArgs: AnyWorkflow.PassedArgs
    private var onFinish = [(AnyWorkflow.PassedArgs) -> Void]()
    private var onAbandon = [() -> Void]()

    @StateObject private var model: WorkflowViewModel
    @StateObject private var launcher: Launcher

    public var body: some View {
        if isLaunched {
            if let body = model.body as? Content {
                body
                    .onReceive(model.onAbandonPublisher) { onAbandon.forEach { $0() } }
                    .onReceive(model.onFinishPublisher, perform: _onFinish)
                    .onChange(of: isLaunched) { if $0 { launch() } }
                    .onReceive(inspection.notice) { inspection.visit(self, $0) }
            } else {
                wrapped?
                    .onReceive(inspection.notice) { inspection.visit(self, $0) }
                    .onReceive(model.onFinishPublisher, perform: _onFinish)
            }
        }
    }

    init<A, FR>(_ workflowView: WorkflowView<A>, isLaunched: Binding<Bool>, item: WorkflowItem<FR, Content>) where Wrapped == Never, Args == FR.WorkflowOutput {
        wrapped = nil
        let wf = AnyWorkflow(Workflow<FR>(item.metadata))
        workflow = wf
        launchArgs = workflowView.passedArgs
        _isLaunched = isLaunched
        let model = WorkflowViewModel(isLaunched: isLaunched)
        _model = StateObject(wrappedValue: model)
        _launcher = StateObject(wrappedValue: Launcher(workflow: wf,
                                                       responder: model,
                                                       launchArgs: workflowView.passedArgs))
    }

    private init<A, W, C, FR>(_ workflowView: ModifiedWorkflowView<A, W, C>, item: WorkflowItem<FR, Content>) where Wrapped == ModifiedWorkflowView<A, W, C>, Args == FR.WorkflowOutput {
        _model = workflowView._model
        wrapped = workflowView
        workflow = workflowView.workflow
        workflow.append(item.metadata)
        launchArgs = workflowView.launchArgs
        _isLaunched = workflowView._isLaunched
        _launcher = workflowView._launcher
//        #warning("Test this")
//        onFinish = workflowView.onFinish
//        onAbandon = workflowView.onAbandon
    }

    private init(workflowView: Self, onFinish: [(AnyWorkflow.PassedArgs) -> Void], onAbandon: [() -> Void]) {
        _model = workflowView._model
        wrapped = workflowView.wrapped
        workflow = workflowView.workflow
        self.onFinish = onFinish
        self.onAbandon = onAbandon
        launchArgs = workflowView.launchArgs
        _isLaunched = workflowView._isLaunched
        _launcher = workflowView._launcher
    }

    private func launch() {
        workflow.launch(withOrchestrationResponder: model, passedArgs: launchArgs)
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
        return Self(workflowView: self, onFinish: onFinish, onAbandon: onAbandon)
    }

    /// Adds an action to perform when this `Workflow` has abandoned.
    public func onAbandon(closure: @escaping () -> Void) -> Self {
        var onAbandon = self.onAbandon
        onAbandon.append(closure)
        return Self(workflowView: self, onFinish: onFinish, onAbandon: onAbandon)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
private final class Launcher: ObservableObject {
    var onFinishCalled = false
    init(workflow: AnyWorkflow,
         responder: OrchestrationResponder,
         launchArgs: AnyWorkflow.PassedArgs) {
        if workflow.orchestrationResponder == nil {
            workflow.launch(withOrchestrationResponder: responder, passedArgs: launchArgs)
        }
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension ModifiedWorkflowView where Args == Never {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `WorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Self, T> where FR.WorkflowInput == Never {
        ModifiedWorkflowView<FR.WorkflowOutput, Self, T>(self, item: item)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension ModifiedWorkflowView where Args == AnyWorkflow.PassedArgs {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `WorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Self, T> where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        ModifiedWorkflowView<FR.WorkflowOutput, Self, T>(self, item: item)
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `WorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Self, T> {
        ModifiedWorkflowView<FR.WorkflowOutput, Self, T>(self, item: item)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension ModifiedWorkflowView {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `WorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Self, T> where Args == FR.WorkflowInput {
        ModifiedWorkflowView<FR.WorkflowOutput, Self, T>(self, item: item)
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `WorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Self, T> where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        ModifiedWorkflowView<FR.WorkflowOutput, Self, T>(self, item: item)
    }
}
