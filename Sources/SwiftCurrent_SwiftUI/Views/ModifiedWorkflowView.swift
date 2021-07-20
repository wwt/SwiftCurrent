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
    let wrapped: Wrapped?
    let inspection = Inspection<Self>()
    let workflow: AnyWorkflow

    @ObservedObject private var model = ViewModel()

    public var body: some View {
        VStack { // THIS SHOULD DIE TOO
            model.body as? Content
            wrapped
        }.onReceive(inspection.notice) { inspection.visit(self, $0) }
    }

    init<A, FR>(_ workflowView: WorkflowView<A>, item: WorkflowItem<FR, Content>) where Wrapped == Never, Args == FR.WorkflowOutput {
        wrapped = nil
        workflow = AnyWorkflow(Workflow<FR>(item.metadata))
    }

    init<A, W, C, FR>(_ workflowView: ModifiedWorkflowView<A, W, C>, item: WorkflowItem<FR, Content>) where Wrapped == ModifiedWorkflowView<A, W, C>, Args == FR.WorkflowOutput {
        model = workflowView.model
        wrapped = workflowView
        workflow = workflowView.workflow
        workflow.append(item.metadata)
        workflow.launch(withOrchestrationResponder: model, passedArgs: .none)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
private final class ViewModel: ObservableObject, OrchestrationResponder {
    @Published var body: Any?

    func launch(to: AnyWorkflow.Element) {
        body = (to.value.instance as? AnyFlowRepresentableView)?.erasedView
    }

    func proceed(to: AnyWorkflow.Element, from: AnyWorkflow.Element) {
        body = (to.value.instance as? AnyFlowRepresentableView)?.erasedView
    }

    func backUp(from: AnyWorkflow.Element, to: AnyWorkflow.Element) { }

    func abandon(_ workflow: AnyWorkflow, onFinish: (() -> Void)?) { }

    func complete(_ workflow: AnyWorkflow, passedArgs: AnyWorkflow.PassedArgs, onFinish: ((AnyWorkflow.PassedArgs) -> Void)?) { }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension ModifiedWorkflowView {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter workflowItem: a `WorkflowItem` that holds onto the next `FlowRepresentable` in the workflow.
     - Returns: a new `WorkflowView` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable & View, T>(with item: WorkflowItem<FR, T>) -> ModifiedWorkflowView<FR.WorkflowOutput, Self, T> where FR.WorkflowInput == Never {
        ModifiedWorkflowView<FR.WorkflowOutput, Self, T>(self, item: item)
    }
}
