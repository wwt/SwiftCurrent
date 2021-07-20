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

    @State private var erasedBody: Any?

    public var body: some View {
        VStack { // THIS SHOULD DIE TOO
            erasedBody as? Content
            wrapped
        }.onReceive(inspection.notice) { inspection.visit(self, $0) }
    }

    init<A, FR>(_ workflowView: WorkflowView<A>, item: WorkflowItem<FR, Content>) where Wrapped == Never, Args == FR.WorkflowOutput {
        wrapped = nil
        workflow = AnyWorkflow(Workflow<FR>(item.metadata))
        let launched = workflow.launch(withOrchestrationResponder: self, passedArgs: .none)
        _erasedBody = State(initialValue: (launched?.value.instance as? AnyFlowRepresentableView)?.erasedView)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension ModifiedWorkflowView: OrchestrationResponder {
    public func launch(to: AnyWorkflow.Element) { }

    public func proceed(to: AnyWorkflow.Element, from: AnyWorkflow.Element) { }

    public func backUp(from: AnyWorkflow.Element, to: AnyWorkflow.Element) { }

    public func abandon(_ workflow: AnyWorkflow, onFinish: (() -> Void)?) { }

    public func complete(_ workflow: AnyWorkflow, passedArgs: AnyWorkflow.PassedArgs, onFinish: ((AnyWorkflow.PassedArgs) -> Void)?) { }
}
