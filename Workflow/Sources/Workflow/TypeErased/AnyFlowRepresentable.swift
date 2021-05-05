//
//  AnyFlowRepresentable.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/25/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//
// swiftlint:disable private_over_fileprivate

import Foundation

fileprivate class AnyFlowRepresentableStorageBase {
    var _workflowPointer: AnyFlowRepresentable?
    var workflow: AnyWorkflow?
    var proceedInWorkflowStorage: ((AnyWorkflow.PassedArgs) -> Void)?
    var backUpInWorkflowStorage: (() throws -> Void)?
    var underlyingInstance: Any {
        fatalError("AnyFlowRepresentableStorageBase called directly, only available internally so something has gone VERY wrong.")
    }

    // https://github.com/Tyler-Keith-Thompson/Workflow/blob/master/STYLEGUIDE.md#type-erasure
    // swiftlint:disable:next unavailable_function
    func shouldLoad() -> Bool {
        fatalError("AnyFlowRepresentableStorageBase called directly, only available internally so something has gone VERY wrong.")
    }
}

fileprivate class AnyFlowRepresentableStorage<FR: FlowRepresentable>: AnyFlowRepresentableStorageBase {
    var holder: FR

    override func shouldLoad() -> Bool {
        holder.shouldLoad()
    }

    override var underlyingInstance: Any {
        holder._workflowUnderlyingInstance
    }

    override var _workflowPointer: AnyFlowRepresentable? {
        get {
            holder._workflowPointer
        } set {
            holder._workflowPointer = newValue
        }
    }

    init(_ instance: inout FR) {
        holder = instance
    }
}

public class AnyFlowRepresentable {
    typealias WorkflowInput = Any
    typealias WorkflowOutput = Any

    /// underlyingInstance: The erased instance that AnyFlowRepresentable wrapped
    public var underlyingInstance: Any {
        _storage.underlyingInstance
    }

    var workflow: AnyWorkflow? {
        get {
            _storage.workflow
        } set {
            _storage.workflow = newValue
        }
    }

    var proceedInWorkflowStorage: ((AnyWorkflow.PassedArgs) -> Void)? {
        get {
            _storage.proceedInWorkflowStorage
        } set {
            _storage.proceedInWorkflowStorage = newValue
        }
    }

    var backUpInWorkflowStorage: (() throws -> Void)? {
        get {
            _storage.backUpInWorkflowStorage
        } set {
            _storage.backUpInWorkflowStorage = newValue
        }
    }

    fileprivate var _storage: AnyFlowRepresentableStorageBase

    init<FR: FlowRepresentable>(_ instance: inout FR) {
        _storage = AnyFlowRepresentableStorage(&instance)
        _storage._workflowPointer = self
    }

    public init<FR: FlowRepresentable>(_ type: FR.Type, args: AnyWorkflow.PassedArgs) {
        switch args {
            case _ where FR.WorkflowInput.self == Never.self:
                var instance = FR._factory(FR.self)
                _storage = AnyFlowRepresentableStorage(&instance)
            case _ where FR.WorkflowInput.self == AnyWorkflow.PassedArgs.self:
                // swiftlint:disable:next force_cast
                var instance = FR(with: args as! FR.WorkflowInput)
                _storage = AnyFlowRepresentableStorage(&instance)
            case .args(let extracted):
                guard let cast = extracted as? FR.WorkflowInput else { fatalError("TYPE MISMATCH: \(String(describing: args)) is not type: \(FR.WorkflowInput.self)") }
                var instance = FR._factory(FR.self, with: cast)
                _storage = AnyFlowRepresentableStorage(&instance)
            default: fatalError("No arguments were passed to representable: \(FR.self), but it expected: \(FR.WorkflowInput.self)")
        }
        _storage._workflowPointer = self
    }

    func shouldLoad() -> Bool { _storage.shouldLoad() }
}
