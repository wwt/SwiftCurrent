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

    fileprivate var storageBase: AnyWorkflowStorageBase

    /// Creates a type erased `Workflow`.
    public init<F>(_ workflow: Workflow<F>) {
        storageBase = AnyWorkflowStorage(workflow)
    }

    // swiftlint:disable:next missing_docs
    public func _abandon() { storageBase._abandon() }
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
    var count: Int { fatalError("Count not overridden by AnyWorkflowStorage") }

    // https://github.com/Tyler-Keith-Thompson/Workflow/blob/master/STYLEGUIDE.md#type-erasure
    // swiftlint:disable:next unavailable_function
    func _abandon() { fatalError("_abandon not overridden by AnyWorkflowStorage") }

    // https://github.com/Tyler-Keith-Thompson/Workflow/blob/master/STYLEGUIDE.md#type-erasure
    // swiftlint:disable:next unavailable_function
    func makeIterator() -> LinkedList<_WorkflowItem>.Iterator { fatalError("makeIterator not overridden by AnyWorkflowStorage") }

    // https://github.com/Tyler-Keith-Thompson/Workflow/blob/master/STYLEGUIDE.md#type-erasure
    // swiftlint:disable:next unavailable_function
    func last(where predicate: (LinkedList<_WorkflowItem>.Element) throws -> Bool) rethrows -> LinkedList<_WorkflowItem>.Element? {
        fatalError("last(where:) not overridden by AnyWorkflowStorage")
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
}
