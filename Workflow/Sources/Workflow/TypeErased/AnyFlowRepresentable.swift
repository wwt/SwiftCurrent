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
    var _workflowPointer: AnyFlowRepresentable?
    func shouldLoad(with args: AnyWorkflow.PassedArgs) -> Bool { fatalError() }

    var workflow: AnyWorkflow?
    var proceedInWorkflowStorage: ((AnyWorkflow.PassedArgs) -> Void)?
    var proceedBackwardInWorkflowStorage: (() -> Void)?
}

class AnyFlowRepresentableStorage<FR: FlowRepresentable>: AnyFlowRepresentableStorageBase {
    var holder: FR

    override func shouldLoad(with args: AnyWorkflow.PassedArgs) -> Bool {
        switch args {
            case _ where FR.WorkflowInput.self == Never.self: return holder.shouldLoad()
                // swiftlint:disable:next force_cast
            case _ where FR.WorkflowInput.self == AnyWorkflow.PassedArgs.self: return holder.shouldLoad(with: args as! FR.WorkflowInput)
            case .args(let extracted):
                guard let cast = extracted as? FR.WorkflowInput else { fatalError("TYPE MISMATCH: \(String(describing: args)) is not type: \(FR.WorkflowInput.self)") }
                return holder.shouldLoad(with: cast)
            default: fatalError("No arguments were passed to representable: \(FR.self), but it expected: \(FR.WorkflowInput.self)")
        }
    }

    override var underlyingInstance: Any {
        return holder._workflowUnderlyingInstance
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

    init<FR: FlowRepresentable>(_ instance: inout FR) {
        _storage = AnyFlowRepresentableStorage(&instance)
        _storage._workflowPointer = self
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

    var proceedBackwardInWorkflowStorage: (() -> Void)? {
        get {
            _storage.proceedBackwardInWorkflowStorage
        } set {
            _storage.proceedBackwardInWorkflowStorage = newValue
        }
    }

    var _storage: AnyFlowRepresentableStorageBase

    public var underlyingInstance: Any {
        _storage.underlyingInstance
    }

    func shouldLoad(with args: AnyWorkflow.PassedArgs) -> Bool { _storage.shouldLoad(with: args) }
    func shouldLoad<T>(with args: T) -> Bool { _storage.shouldLoad(with: .args(args)) }
}
