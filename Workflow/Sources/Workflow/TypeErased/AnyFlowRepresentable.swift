//
//  AnyFlowRepresentable.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/25/19.
//  Copyright © 2019 Tyler Tompson. All rights reserved.
//

import Foundation

class AnyFlowRepresentableStorageBase {
    var underlyingInstance: Any { fatalError() }
    var workflow: AnyWorkflow?
    var _workflowPointer: AnyFlowRepresentable?
    var proceedInWorkflowStorage: ((Any?) -> Void)?
    func shouldLoad(with args: Any?) -> Bool { fatalError() }
}

class AnyFlowRepresentableStorage<FR: FlowRepresentable>: AnyFlowRepresentableStorageBase {
    var holder: FR

    override func shouldLoad(with args: Any?) -> Bool {
        switch args {
            case _ where FR.WorkflowInput.self == Never.self: return holder.shouldLoad()
            default:
                guard let cast = args as? FR.WorkflowInput else { fatalError("TYPE MISMATCH: \(String(describing: args)) is not type: \(FR.WorkflowInput.self)") }
                return holder.shouldLoad(with: cast)

        }
    }

    override var underlyingInstance: Any {
        return holder
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
    func shouldLoad(with args: Any?) -> Bool { _storage.shouldLoad(with: args) }

    typealias WorkflowInput = Any
    typealias WorkflowOutput = Any

    var workflow: AnyWorkflow? {
        get {
            _storage.workflow
        } set {
            _storage.workflow = newValue
        }
    }

    var proceedInWorkflowStorage: ((Any?) -> Void)? {
        get {
            _storage.proceedInWorkflowStorage
        } set {
            _storage.proceedInWorkflowStorage = newValue
        }
    }

    var _storage: AnyFlowRepresentableStorageBase

    public var underlyingInstance: Any {
        _storage.underlyingInstance
    }

    init<FR: FlowRepresentable>(_ instance: inout FR) {
        _storage = AnyFlowRepresentableStorage(&instance)
        instance._workflowPointer = self
        _storage._workflowPointer = self
    }
}
