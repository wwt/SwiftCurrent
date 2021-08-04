// swiftlint:disable:this file_name
// https://github.com/wwt/Workflow/issues/17
//
//  TestOnly.swift
//  Workflow
//
//  Created by Tyler Thompson on 9/25/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.4, *)
extension Notification.Name {
    #if canImport(XCTest)
    /// :nodoc: A notification only available when tests are being run that lets you know a workflow has been launched.
    public static var workflowLaunched: Notification.Name {
        .init(rawValue: "WorkflowLaunched")
    }
    #endif
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.4, *)
extension FlowRepresentable {
    #if canImport(XCTest)
    /// :nodoc: Your tests may want to manually set the closure so they can make assertions it was called, this is simply a convenience available for that.
    public var proceedInWorkflowStorage: ((AnyWorkflow.PassedArgs) -> Void)? {
        get { { _workflowPointer?.proceedInWorkflowStorage?($0) } }
        set {
            _workflowPointer?.proceedInWorkflowStorage = { args in
                newValue?(args)
            }
        }
    }

    /// :nodoc: Designed for V1 and V2 people who used to assign to proceedInWorkflow for tests. This auto extracts args.
    public var _proceedInWorkflow: ((Any?) -> Void)? {
        get { { _workflowPointer?.proceedInWorkflowStorage?(.args($0)) } }
        set {
            _workflowPointer?.proceedInWorkflowStorage = { args in
                newValue?(args.extractArgs(defaultValue: nil))
            }
        }
    }
    #endif
}
