//
//  AnyWorkflow.swift
//  
//
//  Created by Tyler Thompson on 11/25/20.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//
// swiftlint:disable private_over_fileprivate file_types_order

import Foundation

/// A type erased `Workflow`.
public class AnyWorkflow {
    /// The `LinkedList.Node` type of a `Workflow`.
    public typealias Element = LinkedList<_WorkflowItem>.Element

    /// An empty `AnyWorkflow`. Mostly used as a base for dynamically building a workflow.
    public static var empty: AnyWorkflow {
        AnyWorkflow(Workflow<Never>())
    }

    /// The `OrchestrationResponder` of the wrapped `Workflow`.
    public internal(set) var orchestrationResponder: OrchestrationResponder? {
        get {
            storageBase.orchestrationResponder
        } set {
            storageBase.orchestrationResponder = newValue
        }
    }

    /// The count of the wrapped `Workflow`.
    public var count: Int { storageBase.count }

    /// The first `LinkedList.Node` of the wrapped `Workflow`.
    public var first: Element? { storageBase.first }

    fileprivate var storageBase: AnyWorkflowStorageBase

    /// Creates a type erased `Workflow`.
    public init<F>(_ workflow: Workflow<F>) {
        storageBase = AnyWorkflowStorage(workflow)
    }

    // swiftlint:disable:next missing_docs
    public func _abandon() { storageBase._abandon() }

    /// Appends `FlowRepresentableMetadata` to the `Workflow`.
    public func append(_ metadata: FlowRepresentableMetadata) {
        storageBase.append(metadata)
    }

    /**
     Launches the `Workflow`.

     ### Discussion
     passedArgs are passed to the first instance, it has the opportunity to load, not load and transform them, or just not load.
     In the event an instance does not load and does not transform args, they are passed unmodified to the next instance in the `Workflow` until one loads.

     - Parameter orchestrationResponder: the `OrchestrationResponder` to notify when the `Workflow` proceeds or backs up.
     - Parameter passedArgs: the arguments to pass to the first instance(s).
     - Parameter launchStyle: the launch style to use.
     - Parameter onFinish: the closure to call when the last element in the workflow proceeds; called with the `AnyWorkflow.PassedArgs` the workflow finished with.
     - Returns: the first loaded instance or nil, if none was loaded.
     */
    @discardableResult public func launch(withOrchestrationResponder orchestrationResponder: OrchestrationResponder,
                                          passedArgs: AnyWorkflow.PassedArgs,
                                          launchStyle: LaunchStyle = .default,
                                          onFinish: ((AnyWorkflow.PassedArgs) -> Void)? = nil) -> AnyWorkflow.Element? {
        storageBase.launch(withOrchestrationResponder: orchestrationResponder,
                           passedArgs: passedArgs,
                           launchStyle: launchStyle,
                           onFinish: onFinish)
    }
}

extension AnyWorkflow: Sequence {
    /// :nodoc: Sequence protocol requirement.
    public func makeIterator() -> LinkedList<_WorkflowItem>.Iterator {
        storageBase.makeIterator()
    }

    public func last(where predicate: (LinkedList<_WorkflowItem>.Element) throws -> Bool) rethrows -> LinkedList<_WorkflowItem>.Element? {
        try storageBase.last(where: predicate)
    }
}

extension AnyWorkflow {
    /// A type that represents either a type erased value or no value.
    public enum PassedArgs {
        /// No arguments are passed forward.
        case none
        /// The type erased value passed forward.
        case args(Any?)

        /**
         Performs a coalescing operation, returning the type erased value of a `PassedArgs` instance or a default value.

         - Parameter defaultValue: the default value to use if there are no args.
         - Returns: type erased value of a `PassedArgs` instance or a default value.
         */
        public func extractArgs(defaultValue: Any?) -> Any? {
            if case .args(let value) = self {
                return value
            }
            return defaultValue
        }
    }
}

fileprivate class AnyWorkflowStorageBase {
    var orchestrationResponder: OrchestrationResponder?
    var count: Int { fatalError("count not overridden by AnyWorkflowStorage") }
    var first: LinkedList<_WorkflowItem>.Element? { fatalError("first not overridden by AnyWorkflowStorage") }

    // https://github.com/wwt/SwiftCurrent/blob/main/.github/STYLEGUIDE.md#type-erasure
    // swiftlint:disable:next unavailable_function
    func _abandon() { fatalError("_abandon not overridden by AnyWorkflowStorage") }

    // https://github.com/wwt/SwiftCurrent/blob/main/.github/STYLEGUIDE.md#type-erasure
    // swiftlint:disable:next unavailable_function
    func makeIterator() -> LinkedList<_WorkflowItem>.Iterator { fatalError("makeIterator not overridden by AnyWorkflowStorage") }

    // https://github.com/wwt/SwiftCurrent/blob/main/.github/STYLEGUIDE.md#type-erasure
    // swiftlint:disable:next unavailable_function
    func last(where _: (LinkedList<_WorkflowItem>.Element) throws -> Bool) rethrows -> LinkedList<_WorkflowItem>.Element? {
        fatalError("last(where:) not overridden by AnyWorkflowStorage")
    }

    // https://github.com/wwt/SwiftCurrent/blob/main/.github/STYLEGUIDE.md#type-erasure
    // swiftlint:disable:next unavailable_function
    func append(_ metadata: FlowRepresentableMetadata) {
        fatalError("append(:) not overridden by AnyWorkflowStorage")
    }

    // https://github.com/wwt/SwiftCurrent/blob/main/.github/STYLEGUIDE.md#type-erasure
    // swiftlint:disable:next unavailable_function
    @discardableResult func launch(withOrchestrationResponder orchestrationResponder: OrchestrationResponder,
                                   passedArgs: AnyWorkflow.PassedArgs,
                                   launchStyle: LaunchStyle = .default,
                                   onFinish: ((AnyWorkflow.PassedArgs) -> Void)? = nil) -> AnyWorkflow.Element? {
        fatalError("launch(orchestrationResponder:passedArgs:launchStyle:onFinish) not overridden by AnyWorkflowStorage")
    }
}

fileprivate final class AnyWorkflowStorage<F: FlowRepresentable>: AnyWorkflowStorageBase {
    let workflow: Workflow<F>

    override var orchestrationResponder: OrchestrationResponder? {
        get {
            workflow.orchestrationResponder
        }
        set {
            workflow.orchestrationResponder = newValue
        }
    }

    override var count: Int { workflow.count }

    override var first: LinkedList<_WorkflowItem>.Element? { workflow.first }

    init(_ workflow: Workflow<F>) {
        self.workflow = workflow
    }

    override func _abandon() {
        workflow._abandon()
    }

    override func makeIterator() -> LinkedList<_WorkflowItem>.Iterator {
        workflow.makeIterator()
    }

    override func last(where predicate: (LinkedList<_WorkflowItem>.Element) throws -> Bool) rethrows -> LinkedList<_WorkflowItem>.Element? {
        try workflow.last(where: predicate)
    }

    override func append(_ metadata: FlowRepresentableMetadata) {
        workflow.append(metadata)
    }

    override func launch(withOrchestrationResponder orchestrationResponder: OrchestrationResponder,
                         passedArgs: AnyWorkflow.PassedArgs,
                         launchStyle: LaunchStyle = .default,
                         onFinish: ((AnyWorkflow.PassedArgs) -> Void)? = nil) -> AnyWorkflow.Element? {
        workflow.launch(withOrchestrationResponder: orchestrationResponder,
                        passedArgs: passedArgs,
                        launchStyle: launchStyle,
                        onFinish: onFinish)
    }
}
