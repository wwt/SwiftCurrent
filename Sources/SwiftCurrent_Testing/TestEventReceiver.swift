//
//  TestEventReceiver.swift
//  
//
//  Created by Tyler Thompson on 8/8/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  swiftlint:disable file_types_order

import Foundation

#if canImport(SwiftCurrent_Testing_ObjC)
import SwiftCurrent_Testing_ObjC
#endif

@testable import SwiftCurrent

#if canImport(UIKit) && !os(watchOS)
import UIKit
#endif

enum TestEventReceiver {
    static func workflowLaunched(workflow: AnyWorkflow,
                                 responder: OrchestrationResponder,
                                 args: AnyWorkflow.PassedArgs,
                                 style: LaunchStyle,
                                 onFinish: ((AnyWorkflow.PassedArgs) -> Void)?) {
        #if canImport(UIKit) && !os(watchOS)
        if let vc = Mirror(reflecting: responder).descendant("launchedFromVC") as? UIViewController {
            vc.launchedWorkflows.append(workflow)
        }
        #endif
        workflow.onFinish = onFinish
        workflow.launchStyle = style
    }

    static func flowRepresentableMetadataCreated(metadata: FlowRepresentableMetadata, descriptor: String) {
        metadata.flowRepresentableTypeDescriptor = descriptor
    }
}

@available(iOS 11.0, macOS 10.14, tvOS 13, watchOS 7.4, *)
class NotificationReceiver: NSObject {
    @objc static func workflowLaunched(notification: Notification) {
        guard let dict = notification.object as? [String: Any?],
              let workflow = dict["workflow"] as? AnyWorkflow,
              let style = dict["style"] as? LaunchStyle,
              let responder = dict["responder"] as? OrchestrationResponder,
              let args = dict["args"] as? AnyWorkflow.PassedArgs,
              let onFinish = dict["onFinish"] as? ((AnyWorkflow.PassedArgs) -> Void)? else {
            fatalError("WorkflowLaunched notification has incorrect format, this may be because you need to update SwiftCurrent_Testing")
        }

        TestEventReceiver.workflowLaunched(workflow: workflow,
                                       responder: responder,
                                       args: args,
                                       style: style,
                                       onFinish: onFinish)
    }

    @objc static func flowRepresentableMetadataCreated(notification: Notification) {
        guard let dict = notification.object as? [String: Any],
              let metadata = dict["metadata"] as? FlowRepresentableMetadata,
              let type = dict["type"] as? String else {
            fatalError("FlowRepresentableMetadataCreated notification has incorrect format, this may be because you need to update SwiftCurrent_Testing")
        }

        TestEventReceiver.flowRepresentableMetadataCreated(metadata: metadata, descriptor: type)
    }
}

@nonobjc extension NotificationCenter {
    @objc override public class func beforeTestExecution() {
        if #available(iOS 11.0, macOS 10.14, tvOS 13, watchOS 7.4, *) {
            NotificationCenter.default.addObserver(NotificationReceiver.self,
                                                   selector: #selector(NotificationReceiver.workflowLaunched(notification:)),
                                                   name: .workflowLaunched,
                                                   object: nil)
            NotificationCenter.default.addObserver(NotificationReceiver.self,
                                                   selector: #selector(NotificationReceiver.flowRepresentableMetadataCreated(notification:)),
                                                   name: .flowRepresentableMetadataCreated,
                                                   object: nil)
        }
    }
}

@available(iOS 11.0, macOS 10.14, tvOS 13, watchOS 7.4, *)
extension FlowRepresentable {
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
}
