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
    associatedtype WorkflowInput
    associatedtype WorkflowOutput = Never

    var _workflowPointer: AnyFlowRepresentable? { get set }
    var _workflowUnderlyingInstance: Any { get }

    init()
    init(with args: WorkflowInput)
    static func _factory<FR: FlowRepresentable>(_ type: FR.Type) -> FR
    static func _factory<FR: FlowRepresentable>(_ type: FR.Type, with args: WorkflowInput) -> FR

    /**
    A method indicating whether it makes sense for this view to load in a workflow
    - Parameter args: Note you can rename this in your implementation if 'args' doesn't make sense.
    - Returns: Bool
    - Note: This method is called *before* your view loads. Do not attempt to do any UI work in this method. This is however a good place to set up data on your view.
    */
    mutating func shouldLoad(with args: WorkflowInput) -> Bool
    mutating func shouldLoad() -> Bool
}

extension FlowRepresentable {
    public var _workflowUnderlyingInstance: Any { self }

    // swiftlint:disable:next line_length unavailable_function
    public init() { fatalError("This initializer was only designed to satisfy a protocol requirement on FlowRepresentables. You must implement your own custom intializer on \(String(describing: Self.self))") }
    // swiftlint:disable:next force_cast
    public static func _factory<FR: FlowRepresentable>(_: FR.Type) -> FR { Self() as! FR }
    // swiftlint:disable:next force_cast
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

    public mutating func shouldLoad() -> Bool { fatalError("This shouldLoad method should only be called if the WorkflowInput is Never") }
    public mutating func shouldLoad(with _: WorkflowInput) -> Bool { true }
}

extension FlowRepresentable where WorkflowInput == Never {
    @available(*, unavailable)
    public init() { fatalError() }

    @available(*, renamed: "init()")
    // swiftlint:disable:next unavailable_function
    public init(with args: WorkflowInput) { fatalError("Because the FlowRepresentable does not take an input this initializer will not work") }

    /**
    A method indicating whether it makes sense for this view to load in a workflow
    - Returns: Bool
    - Note: This particular version of shouldLoad is only available when your `WorkflowInput` is `Never`, indicating you do not care about data passed to this view
    */
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

    public func proceedBackwardInWorkflow() {
        _workflowPointer?.proceedBackwardInWorkflowStorage?()
    }
}
