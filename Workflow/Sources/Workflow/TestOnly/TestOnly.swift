//
//  TestOnly.swift
//  Workflow
//
//  Created by Tyler Thompson on 9/25/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation

#if canImport(XCTest)
public extension Notification.Name {
    static var workflowLaunched: Notification.Name {
        return Notification.Name(rawValue: "WorkflowLaunched")
    }
}

public extension FlowRepresentable {
    var proceedInWorkflowStorage: ((Any?) -> Void)? {
        get {
            _workflowPointer?.proceedInWorkflowStorage
        }
        set {
            _workflowPointer?.proceedInWorkflowStorage = newValue
        }
    }

    var _proceedInWorkflow: ((Any?) -> Void)? {
        get {
            _workflowPointer?.proceedInWorkflowStorage
        }
        set {
            _workflowPointer?.proceedInWorkflowStorage = newValue
        }
    }
}
#endif
