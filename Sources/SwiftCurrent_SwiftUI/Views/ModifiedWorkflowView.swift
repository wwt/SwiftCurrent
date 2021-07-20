//
//  ModifiedWorkflowView.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 7/20/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

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

    public var body: some View {
        if isLaunched {
            if let body = model.erasedBody as? Content {
                body
                    .onReceive(model.onAbandonPublisher) { onAbandon.forEach { $0() } }
                    .onReceive(inspection.notice) { inspection.visit(self, $0) }
            } else {
                wrapped.onReceive(inspection.notice) { inspection.visit(self, $0) }
            }
        }
    }

    init<A, FR>(_ workflowView: WorkflowView<A>, isLaunched: Binding<Bool>, item: WorkflowItem<FR, Content>) where Wrapped == Never, Args == FR.WorkflowOutput {
        wrapped = nil
        workflow = AnyWorkflow(Workflow<FR>(item.metadata))
        launchArgs = workflowView.passedArgs
        _isLaunched = isLaunched
        _model = ObservedObject(initialValue: WorkflowViewModel(isLaunched: isLaunched))
    }

    init<A, W, C, FR>(_ workflowView: ModifiedWorkflowView<A, W, C>, item: WorkflowItem<FR, Content>) where Wrapped == ModifiedWorkflowView<A, W, C>, Args == FR.WorkflowOutput {
        model = workflowView.model
        wrapped = workflowView
        workflow = workflowView.workflow
        workflow.append(item.metadata)
        launchArgs = workflowView.launchArgs
        _isLaunched = workflowView._isLaunched
    }

    private init(workflowView: Self, onFinish: [(AnyWorkflow.PassedArgs) -> Void], onAbandon: [() -> Void]) {
        model = workflowView.model
        wrapped = workflowView.wrapped
        workflow = workflowView.workflow
        self.onFinish = onFinish
        self.onAbandon = onAbandon
        launchArgs = workflowView.launchArgs
        _isLaunched = workflowView._isLaunched
    }

    public func launch() -> Self {
        workflow.launch(withOrchestrationResponder: model, passedArgs: launchArgs) { args in
            onFinish.forEach { $0(args) }
        }
        return self
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
