// swiftlint:disable:this file_name
// https://github.com/wwt/Workflow/issues/17
//
//  TestOnly.swift
//  Workflow
//
//  Created by Tyler Thompson on 9/25/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//
// swiftlint:disable file_types_order

import Foundation

@available(iOS 11.0, macOS 10.14, tvOS 13, watchOS 7.4, *)
extension Notification.Name {
    #if canImport(XCTest)
    /// :nodoc: A notification only available when tests are being run that lets you know a workflow has been launched.
    public static var workflowLaunched: Notification.Name {
        .init(rawValue: "WorkflowLaunched")
    }
    #endif
}

// internal class that essentially delegates to SwiftCurrent_Testing. You cannot directly import that library without creating a circular reference so you need a middle man, like NotificationCenter.
enum EventReceiver {
    static func workflowLaunched(workflow: AnyWorkflow,
                                 responder: OrchestrationResponder,
                                 args: AnyWorkflow.PassedArgs,
                                 style: LaunchStyle,
                                 onFinish: ((AnyWorkflow.PassedArgs) -> Void)?) {
        #if canImport(XCTest)
        NotificationCenter.default.post(name: .workflowLaunched, object: [
            "workflow": workflow,
            "responder": responder,
            "args": args,
            "style": style,
            "onFinish": onFinish as Any
        ])
        #endif
    }
}
