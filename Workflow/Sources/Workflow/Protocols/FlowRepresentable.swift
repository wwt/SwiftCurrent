//
//  FlowRepresentable.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/25/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation

/**
 FlowRepresentable: A typed version of 'AnyFlowRepresentable'. Use this on views that you want to add to a workflow.
 
 ### Discussion:
 It's important to make sure your FlowRepresentable is not dependent on other views. It's okay to specify that a certain kind of data needs to be passed in, but keep your views from knowing what came before or what's likely to come after. In that way you'll end up with pieces of a workflow that can be moved, or put into multiple places with ease. Notice the 'Instance' method. This is needed for Workflow to create a new instance of your view. Make sure that this function always returns a new, unique instance of your class. Note that this is still accomplishable whether the view is created programmatically or in a storyboard.
 */

public protocol FlowRepresentable {
    /// WorkflowInput: The data type required to be passed to your FlowRepresentable (use `Any?` if you don't care)
    associatedtype WorkflowInput
    associatedtype WorkflowOutput = Never

    var _workflowPointer: AnyFlowRepresentable? { get set }
    var _workflowUnderlyingInstance: Any { get }
    /// instance: A method to return an instance of the `FlowRepresentable`
    /// - Returns: `AnyFlowRepresentable`. Specifically a new instance from the static class passed to a `Workflow`
    /// - Note: This needs to return a unique instance of your view. Whether programmatic or from the storyboard is irrelevant
    static func instance() -> Self

    /// shouldLoad: A method indicating whether it makes sense for this view to load in a workflow
    /// - Parameter args: Note you can rename this in your implementation if 'args' doesn't make sense.
    /// - Returns: Bool
    /// - Note: This method is called *before* your view loads. Do not attempt to do any UI work in this method. This is however a good place to set up data on your view.
    mutating func shouldLoad(with args: WorkflowInput) -> Bool
    mutating func shouldLoad() -> Bool
}

extension FlowRepresentable {
    public var _workflowUnderlyingInstance: Any { self }
}

extension FlowRepresentable {
    /// workflow: Access to the `Workflow` controlling the `FlowRepresentable`. A common use case may be a `FlowRepresentable` that wants to abandon the `Workflow` it's in.
    /// - Note: While not strictly necessary it would be wise to declare this property as `weak`
    public var workflow: AnyWorkflow? {
        _workflowPointer?.workflow
    }

    public func proceedBackwardInWorkflow() {
        _workflowPointer?.proceedBackwardInWorkflowStorage?()
    }

    public mutating func shouldLoad() -> Bool { true }
}

extension FlowRepresentable where WorkflowInput == Never {
    public mutating func shouldLoad(with _: Never) -> Bool {
        // This cannot execute because it takes in Never. There is no implementation possible for this function.
    }

    /// shouldLoad: A method indicating whether it makes sense for this view to load in a workflow
    /// - Returns: Bool
    /// - Note: This particular version of shouldLoad is only available when your `WorkflowInput` is `Never`, indicating you do not care about data passed to this view
    public mutating func shouldLoad() -> Bool { true }
}

extension FlowRepresentable where WorkflowOutput == Never {
    public func proceedInWorkflow() {
        _workflowPointer?.proceedInWorkflowStorage?(.none)
    }
}

extension FlowRepresentable {
    public func proceedInWorkflow(_ args: WorkflowOutput) {
        _workflowPointer?.proceedInWorkflowStorage?(.args(args))
    }
}
