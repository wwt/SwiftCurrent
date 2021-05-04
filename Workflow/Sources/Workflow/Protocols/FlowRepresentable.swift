//
//  FlowRepresentable.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/25/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation

/**
 A component in a `Workflow`; should be independent of the workflow context.
 
 ### Discussion:
 It's important to make sure your `FlowRepresentable` is not dependent on other `FlowRepresentable`s.
 It's okay to specify that a certain kind of data needs to be passed in and passed out, but keep your `FlowRepresentable` from knowing what came before, or what's likely to come after.
 In that way you'll end up with pieces of a workflow that can be moved or put into multiple places with ease.
 Declare an input type of `Never` when your `FlowRepresentable` does not care about data passed in.
 Declare an output type of `Never` when your `FlowRepresentable` will not pass data forward in the `Workflow`.
 SOMETHING HERE ABOUT _workflowPointer

 */

public protocol FlowRepresentable {
    /// The type of data coming into the `FlowRepresentable`; use `Never` when the `FlowRepresentable` will ignore the data.
    associatedtype WorkflowInput
    /// The type of data passed forward from the `FlowRepresentable`; `Never` means data will not be passed forward.
    associatedtype WorkflowOutput = Never

    var _workflowPointer: AnyFlowRepresentable? { get set }
    var _workflowUnderlyingInstance: Any { get }

    init()
    init(with args: WorkflowInput)

    // No public docs necessary, as this should not be used by consumers.
    // swiftlint:disable:next missing_docs
    static func _factory<FR: FlowRepresentable>(_ type: FR.Type) -> FR
    // No public docs necessary, as this should not be used by consumers.
    // swiftlint:disable:next missing_docs
    static func _factory<FR: FlowRepresentable>(_ type: FR.Type, with args: WorkflowInput) -> FR

    /**
    A method indicating whether it makes sense for this `FlowRepresentable` to load in a `Workflow`
    - Returns: Bool
    - Note: This method is called *before* your view loads. Do not attempt to do any UI work in this method. This is however a good place to set up data on your view.
    - Note: This method is called *after* `init` but *before* any other lifecycle events. It is non-mutating
    */
    func shouldLoad() -> Bool
}

extension FlowRepresentable {
    public var _workflowUnderlyingInstance: Any { self }

    // swiftlint:disable:next line_length unavailable_function
    public init() { fatalError("This initializer was only designed to satisfy a protocol requirement on FlowRepresentables. You must implement your own custom intializer on \(String(describing: Self.self))") }
    // No public docs necessary, as this should not be used by consumers.
    // swiftlint:disable:next missing_docs force_cast
    public static func _factory<FR: FlowRepresentable>(_: FR.Type) -> FR { Self() as! FR }
    // No public docs necessary, as this should not be used by consumers.
    // swiftlint:disable:next missing_docs force_cast
    public static func _factory<FR: FlowRepresentable>(_: FR.Type, with args: WorkflowInput) -> FR { Self(with: args) as! FR }
}

extension FlowRepresentable {
    /**
    Access to the `AnyWorkflow` controlling the `FlowRepresentable`. A common use case may be a `FlowRepresentable` that wants to abandon the `Workflow` it's in.
    - Note: While not strictly necessary it would be wise to declare this property as `weak`
    */
    public var workflow: AnyWorkflow? {
        _workflowPointer?.workflow
    }

    public func shouldLoad() -> Bool { true }
}

extension FlowRepresentable where WorkflowInput == Never {
    @available(*, unavailable)
    public init() { fatalError() }

    @available(*, renamed: "init()")
    // swiftlint:disable:next unavailable_function
    public init(with args: WorkflowInput) { fatalError("Because the FlowRepresentable does not take an input this initializer will not work") }
}

extension FlowRepresentable where WorkflowOutput == Never {
    /// Moves forward in the `Workflow`; if at the end, completes the workflow.
    public func proceedInWorkflow() {
        _workflowPointer?.proceedInWorkflowStorage?(.none)
    }
}

extension FlowRepresentable {
    /// Moves forward in the `Workflow` passing arguments forward; if at the end, completes the workflow.
    public func proceedInWorkflow(_ args: WorkflowOutput) {
        _workflowPointer?.proceedInWorkflowStorage?(.args(args))
    }

    public func proceedBackwardInWorkflow() {
        _workflowPointer?.proceedBackwardInWorkflowStorage?()
    }
}
