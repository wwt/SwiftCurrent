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

    @ObservedObject private var model: WorkflowViewModel
    @StateObject private var launcher: Launcher

    public var body: some View {
        if isLaunched {
            if let body = model.erasedBody as? Content {
                body
                    .onReceive(model.onAbandonPublisher) { onAbandon.forEach { $0() } }
                    .onChange(of: isLaunched) { if $0 { launch() } }
                    .onReceive(inspection.notice) { inspection.visit(self, $0) }
            } else {
                wrapped.onReceive(inspection.notice) { inspection.visit(self, $0) }
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
        _model = ObservedObject(initialValue: model)
        _launcher = StateObject(wrappedValue: Launcher(workflow: wf,
                                                       responder: model,
                                                       launchArgs: workflowView.passedArgs))
    }

    init<A, W, C, FR>(_ workflowView: ModifiedWorkflowView<A, W, C>, item: WorkflowItem<FR, Content>) where Wrapped == ModifiedWorkflowView<A, W, C>, Args == FR.WorkflowOutput {
        model = workflowView.model
        wrapped = workflowView
        workflow = workflowView.workflow
        workflow.append(item.metadata)
        launchArgs = workflowView.launchArgs
        _isLaunched = workflowView._isLaunched
        _launcher = workflowView._launcher
    }

    private init(workflowView: Self, onFinish: [(AnyWorkflow.PassedArgs) -> Void], onAbandon: [() -> Void]) {
        model = workflowView.model
        wrapped = workflowView.wrapped
        workflow = workflowView.workflow
        self.onFinish = onFinish
        self.onAbandon = onAbandon
        launchArgs = workflowView.launchArgs
        _isLaunched = workflowView._isLaunched
        _launcher = StateObject(wrappedValue: Launcher(workflow: workflowView.workflow,
                                                       responder: workflowView.model,
                                                       launchArgs: workflowView.launchArgs) { args in
            onFinish.forEach { $0(args) }
        })

    }

    private func launch() {
        workflow.launch(withOrchestrationResponder: model, passedArgs: launchArgs) { args in
            onFinish.forEach { $0(args) }
        }
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
    init(workflow: AnyWorkflow,
         responder: OrchestrationResponder,
         launchArgs: AnyWorkflow.PassedArgs,
         onFinish: ((AnyWorkflow.PassedArgs) -> Void)? = nil) {
        if workflow.orchestrationResponder == nil {
            workflow.launch(withOrchestrationResponder: responder, passedArgs: launchArgs) {
                onFinish?($0)
            }
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
