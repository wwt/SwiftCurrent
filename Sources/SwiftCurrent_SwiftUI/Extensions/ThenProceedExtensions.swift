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

/**
 Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
 - Parameter with: a `FlowRepresentable` type that should be presented.
 - Returns: a new `WorkflowItem` with the additional `FlowRepresentable` item.
 - NOTE: Should be called inside a `WorkflowLauncher` initializer.
 - IMPORTANT: Not for use in UIKit, unless you're doing SwiftUI interop.
 */
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public func thenProceed<FR: FlowRepresentable & View>(with: FR.Type) -> WorkflowItem<FR, Never, FR> {
    WorkflowItem(FR.self)
}

/**
 Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
 - Parameter with: a `FlowRepresentable` type that should be presented.
 - Parameter nextItem: a closure returning the next item in the `Workflow`.
 - Returns: a new `WorkflowItem` with the additional `FlowRepresentable` item.
 - NOTE: Should be called inside a `WorkflowLauncher` initializer.
 - IMPORTANT: Not for use in UIKit, unless you're doing SwiftUI interop.
 */
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public func thenProceed<FR: FlowRepresentable & View, F, W, C>(with: FR.Type, nextItem: () -> WorkflowItem<F, W, C>) -> WorkflowItem<FR, WorkflowItem<F, W, C>, FR> {
    verifyWorkflowIsWellFormed(FR.self, F.self)
    return WorkflowItem(FR.self) { nextItem() }
}

#if (os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)) && canImport(UIKit)
/**
 Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
 - Parameter with: a `FlowRepresentable` type that should be presented.
 - Returns: a new `WorkflowItem` with the additional `FlowRepresentable` item.
 - NOTE: Should be called inside a `WorkflowLauncher` initializer.
 - IMPORTANT: Not for use in UIKit, unless you're doing SwiftUI interop.
 */
@available(iOS 14.0, macOS 11, tvOS 14.0, *)
public func thenProceed<VC: FlowRepresentable & UIViewController>(with: VC.Type) -> WorkflowItem<ViewControllerWrapper<VC>, Never, ViewControllerWrapper<VC>> {
    WorkflowItem(VC.self)
}

/**
 Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
 - Parameter with: a `FlowRepresentable` type that should be presented.
 - Parameter nextItem: a closure returning the next item in the `Workflow`.
 - Returns: a new `WorkflowItem` with the additional `FlowRepresentable` item.
 - NOTE: Should be called inside a `WorkflowLauncher` initializer.
 - IMPORTANT: Not for use in UIKit, unless you're doing SwiftUI interop.
 */
@available(iOS 14.0, macOS 11, tvOS 14.0, *)
public func thenProceed<VC: FlowRepresentable & UIViewController, F, W, C>(with: VC.Type, nextItem: () -> WorkflowItem<F, W, C>) -> WorkflowItem<ViewControllerWrapper<VC>, WorkflowItem<F, W, C>, ViewControllerWrapper<VC>> {
    verifyWorkflowIsWellFormed(VC.self, F.self)
    return WorkflowItem(VC.self) { nextItem() }
}
#endif
