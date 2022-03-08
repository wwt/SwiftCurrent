//
//  ThenProceedExtensions.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Brian Lombardo on 8/24/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation
import SwiftCurrent
import SwiftUI

private func verifyWorkflowIsWellFormed<LHS: FlowRepresentable, RHS: FlowRepresentable>(_ lhs: LHS.Type, _ rhs: RHS.Type) {
    guard !(RHS.WorkflowInput.self is Never.Type), // an input type of `Never` indicates any arguments will simply be ignored
          !(RHS.WorkflowInput.self is AnyWorkflow.PassedArgs.Type), // an input type of `AnyWorkflow.PassedArgs` means either some value or no value can be passed
          !(LHS.WorkflowOutput.self is AnyWorkflow.PassedArgs.Type) else { return } // an output type of `AnyWorkflow.PassedArgs` can only be checked at runtime when the actual value is passed forward

    // trap if workflow is malformed (output does not match input)
    assert(LHS.WorkflowOutput.self is RHS.WorkflowInput.Type, "Workflow is malformed, expected output of: \(LHS.self) (\(LHS.WorkflowOutput.self)) to match input of: \(RHS.self) (\(RHS.WorkflowInput.self)")
}
