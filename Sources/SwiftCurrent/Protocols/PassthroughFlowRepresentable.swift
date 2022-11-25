//
//  PassthroughFlowRepresentable.swift
//  Workflow
//
//  Created by Tyler Thompson on 7/22/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

// swiftlint:disable:next missing_docs
public protocol _PassthroughIdentifiable { } // swiftlint:disable:this type_name

/// A `FlowRepresentable` that automatically captures data from the `Workflow` and passes it forward.
public protocol PassthroughFlowRepresentable: FlowRepresentable, _PassthroughIdentifiable where WorkflowInput == AnyWorkflow.PassedArgs, WorkflowOutput == AnyWorkflow.PassedArgs { }

extension PassthroughFlowRepresentable {
    // swiftlint:disable:next missing_docs
    public init(with args: WorkflowInput) { self.init() }

    /// Moves forward in the `Workflow`; if at the end, calls the `onFinish` closure used when launching the workflow.
    public func proceedInWorkflow() {
        guard let pointer = _workflowPointer else {
            fatalError("Cannot proceed in workflow, no workflow pointer found.")
        }
        pointer.proceedInWorkflowStorage?(pointer.argsHolder)
    }
}
