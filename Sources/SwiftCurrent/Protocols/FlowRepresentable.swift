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

 - Important: Declare an **input** type of `Never` when the `FlowRepresentable` will ignore data passed in from the `Workflow`.  An **output** type of `Never` means data will not be passed forward.
 - Important: A `_workflowPointer` has to be declared as a property on the type conforming to `FlowRepresentable` but it is set by the `Workflow`, and should not be set by anything else.
 - Important: If you create a superclass that is a `FlowRepresentable` and expect subclasses to be able to define their own methods, such as `shouldLoad`, the superclass should declare those methods, and the subclasses should override them. Otherwise you will find the subclasses do not behave as expected.

 #### Example
 A `FlowRepresentable` with a `WorkflowInput` of `String` and a `WorkflowOutput` of `Never`
 ```swift
 class FR1: FlowRepresentable { // Mark this class as `final` to avoid the required keyword on init
    weak var _workflowPointer: AnyFlowRepresentable?
    required init(with name: String) { }
 }
 ```

 A `FlowRepresentable` with a `WorkflowInput` of `Never` and a `WorkflowOutput` of `Never`
 ```swift
 final class FR1: FlowRepresentable { // Classes synthesize an empty initializer already, you are good!
    weak var _workflowPointer: AnyFlowRepresentable?
 }
 ```

 #### Note
 Declaring your own custom initializer can result in a compiler error with an unfriendly message
 ```swift
 class FR1: FlowRepresentable { // Results in compiler error for 'init()' being unavailable
    weak var _workflowPointer: AnyFlowRepresentable?
    init(myCustomInitializer property: Int) { }
    // required init() { } // declare your own init() to satisfy the protocol requirements and handle the compiler error
 }
 ```
 */
public protocol FlowRepresentable {
    /// The type of data coming into the `FlowRepresentable`; defaulted to `Never`; `Never`means the `FlowRepresentable` will ignore data passed in from the `Workflow`.
    associatedtype WorkflowInput = Never
    /// The type of data passed forward from the `FlowRepresentable`; defaulted to `Never`; `Never` means data will not be passed forward.
    associatedtype WorkflowOutput = Never

    /**
     A pointer to the `AnyFlowRepresentable` that erases this `FlowRepresentable`; will automatically be set.

     ### Discussion
     This property is automatically set by a `Workflow`, it simply needs to be declared on a `FlowRepresentable`.
     In order for a `FlowRepresentable` to have access to the `Workflow` that launched it, store the closures for proceeding forward and backward, and provide type safety, it needs this property available for writing.

     #### Note
     While not strictly necessary it would be wise to declare this property as `weak`.
     */
    var _workflowPointer: AnyFlowRepresentable? { get set }

    /**
     Creates a `FlowRepresentable`.

     #### Note
     This is auto synthesized by FlowRepresentable, and is only called when `WorkflowInput` is `Never`.
     */
    init()
    /// Creates a `FlowRepresentable` with the specified `WorkflowInput`.
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

     - Important: If you create a superclass that is a `FlowRepresentable` and expect subclasses to define their own `shouldLoad` the superclass should declare `shouldLoad`, and the subclasses should override it. Otherwise you will find the subclasses do not behave as expected.

     #### Note
     Returning `false` can have different behaviors depending on the `FlowPersistence`.
     */
    func shouldLoad() -> Bool
}

extension FlowRepresentable {
    // No public docs necessary, as this should not be used by consumers.
    // swiftlint:disable:next missing_docs
    public var _workflowUnderlyingInstance: Any { self }

    /// :nodoc: **WARNING: This will throw a fatal error.** Just a default implementation of the required `FlowRepresentable` initializer meant to satisfy the protocol requirements.
    public init() { // swiftlint:disable:this unavailable_function
        fatalError("This initializer was only designed to satisfy a protocol requirement on FlowRepresentable. You must implement your own custom initializer on \(String(describing: Self.self))")
    }

    // No public docs necessary, as this should not be used by consumers.
    // swiftlint:disable:next missing_docs force_cast
    public static func _factory<FR: FlowRepresentable>(_: FR.Type) -> FR { Self() as! FR }
    // No public docs necessary, as this should not be used by consumers.
    // swiftlint:disable:next missing_docs force_cast
    public static func _factory<FR: FlowRepresentable>(_ type: FR.Type, with args: WorkflowInput) -> FR { FR(with: args as! FR.WorkflowInput) }
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

extension FlowRepresentable where WorkflowOutput == AnyWorkflow.PassedArgs {
    /// Moves forward while passing arguments forward in the `Workflow`; if at the end, calls the `onFinish` closure used when launching the workflow.
    public func proceedInWorkflow(_ args: WorkflowOutput) {
        _workflowPointer?.proceedInWorkflowStorage?(args)
    }
}

extension FlowRepresentable {
    /// Moves forward while passing arguments forward in the `Workflow`; if at the end, calls the `onFinish` closure used when launching the workflow.
    public func proceedInWorkflow(_ args: WorkflowOutput) {
        _workflowPointer?.proceedInWorkflowStorage?(.args(args))
    }

    /**
     Backs up in the `Workflow`.

     - Throws: `WorkflowError` when the `Workflow` is unable to back up.
     */
    public func backUpInWorkflow() throws {
        try _workflowPointer?.backUpInWorkflowStorage?()
    }
}
