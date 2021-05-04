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
 
 ### Discussion
 It's important to make sure your `FlowRepresentable` is not dependent on other `FlowRepresentable`s.
 It's okay to specify that a certain kind of data needs to be passed in and passed out, but keep your `FlowRepresentable` from knowing what came before, or what's likely to come after.
 In that way you'll end up with pieces of a workflow that can be moved or put into multiple places with ease.
 Declare an input type of `Never` when the `FlowRepresentable` will ignore data passed in from the `Workflow`.
 An output type of `Never` means data will not be passed forward.

 SOMETHING HERE ABOUT _workflowPointer

 */

public protocol FlowRepresentable {
    /// The type of data coming into the `FlowRepresentable`; use `Never` when the `FlowRepresentable` will ignore data passed in from the `Workflow`.
    associatedtype WorkflowInput
    /// The type of data passed forward from the `FlowRepresentable`; `Never` means data will not be passed forward.
    associatedtype WorkflowOutput = Never

    /// - Note: While not strictly necessary it would be wise to declare this property as `weak`
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
     Returns a Boolean indicating the `Workflow` should load the `FlowRepresentable`; defaults to `true`.

     ### Discussion
     This method is called *after* `init` but *before* any other lifecycle events. It is non-mutating and should not change the `FlowRepresentable`.
     - Note: Returning `false` can have different behaviors depending on the `FlowPersistence`.
     */
    func shouldLoad() -> Bool
}

extension FlowRepresentable {
    // No public docs necessary, as this should not be used by consumers.
    // swiftlint:disable:next missing_docs
    public var _workflowUnderlyingInstance: Any { self }

    /// :nodoc: **WARNING: This will throw a fatal error.** Just a default implementation of the required `FlowRepresentable` initializer meant to satisfy the protocol requirements.
    public init() { // swiftlint:disable:this unavailable_function
        // swiftlint:disable:next line_length
        fatalError("This initializer was only designed to satisfy a protocol requirement on FlowRepresentable. You must implement your own custom initializer on \(String(describing: Self.self))")
    }

    // No public docs necessary, as this should not be used by consumers.
    // swiftlint:disable:next missing_docs force_cast
    public static func _factory<FR: FlowRepresentable>(_: FR.Type) -> FR { Self() as! FR }
    // No public docs necessary, as this should not be used by consumers.
    // swiftlint:disable:next missing_docs force_cast
    public static func _factory<FR: FlowRepresentable>(_: FR.Type, with args: WorkflowInput) -> FR { Self(with: args) as! FR }
}

extension FlowRepresentable {
    /**
     Access to the `AnyWorkflow` controlling the `FlowRepresentable`.

     ### Discussion
     A common use case may be a `FlowRepresentable` that wants to abandon the `Workflow` it's in.
     */
    public var workflow: AnyWorkflow? {
        _workflowPointer?.workflow
    }

    // False positive: Inherited docs
    // swiftlint:disable:next missing_docs
    public func shouldLoad() -> Bool { true }
}

extension FlowRepresentable where WorkflowInput == Never {
    @available(*, unavailable, message: "Is not called due to input type of Never.")
    // swiftlint:disable:next missing_docs
    public init() { fatalError("Because this initializer is marked unavailable, this init cannot be called.") }

    @available(*, renamed: "init()")
    // swiftlint:disable:next unavailable_function missing_docs
    public init(with args: WorkflowInput) { fatalError("Because the FlowRepresentable does not take an input this initializer will not work") }
}

extension FlowRepresentable where WorkflowOutput == Never {
    /// Moves forward in the `Workflow`; if at the end, calls the `onFinish` closure used when launching the workflow.
    public func proceedInWorkflow() {
        _workflowPointer?.proceedInWorkflowStorage?(.none)
    }
}

extension FlowRepresentable {
    /// Moves forward while passing arguments forward in the `Workflow`; if at the end, calls the `onFinish` closure used when launching the workflow.
    public func proceedInWorkflow(_ args: WorkflowOutput) {
        _workflowPointer?.proceedInWorkflowStorage?(.args(args))
    }

    #warning("Discuss more what it means to move backwards at the beginning of a workflow. Throws?")
    /// Moves backward in the `Workflow`.
    public func proceedBackwardInWorkflow() {
        _workflowPointer?.proceedBackwardInWorkflowStorage?()
    }
}
