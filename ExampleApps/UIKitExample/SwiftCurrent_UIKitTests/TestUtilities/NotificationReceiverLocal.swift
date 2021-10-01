//
//  NotificationReceiverLocal.swift
//  SwiftCurrent
//
//  Created by Richard Gist on 10/1/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftCurrent

protocol WorkflowTestingReceiver {
    static var workflowTestingData: WorkflowTestingData? { get set }
}

// MARK: WORST TESTING WORKAROUND EVA!!!
class NotificationReceiverLocal: NSObject {
    @objc static func workflowLaunched(notification: Notification) {
        guard let dict = notification.object as? [String: Any?],
              let workflow = dict["workflow"] as? AnyWorkflow,
              let style = dict["style"] as? LaunchStyle,
              let responder = dict["responder"] as? OrchestrationResponder,
              let args = dict["args"] as? AnyWorkflow.PassedArgs,
              let onFinish = dict["onFinish"] as? ((AnyWorkflow.PassedArgs) -> Void)? else {
            fatalError("WorkflowLaunched notification has incorrect format, this may be because you need to update SwiftCurrent_Testing")
        }

        NotificationReceiverLocal.workflowLaunched(workflow: workflow,
                                                   responder: responder,
                                                   args: args,
                                                   style: style,
                                                   onFinish: onFinish)
    }

    static func workflowLaunched(workflow: AnyWorkflow,
                                 responder: OrchestrationResponder,
                                 args: AnyWorkflow.PassedArgs,
                                 style: LaunchStyle,
                                 onFinish: ((AnyWorkflow.PassedArgs) -> Void)?) {
        receivers.forEach { $0.workflowTestingData = WorkflowTestingData(workflow: workflow, orchestrationResponder: responder, args: args, style: style, onFinish: onFinish) }
    }

    private static var receivers = [WorkflowTestingReceiver.Type]()

    static func register(on notificationCenter: NotificationCenter, for receiver: WorkflowTestingReceiver.Type) {
        notificationCenter.addObserver(NotificationReceiverLocal.self,
                                       selector: #selector(NotificationReceiverLocal.workflowLaunched(notification:)),
                                       name: .workflowLaunched,
                                       object: nil)
        receivers.append(receiver)
    }

    static func unregister(on notificationCenter: NotificationCenter, for receiver: WorkflowTestingReceiver.Type) {
        notificationCenter.removeObserver(NotificationReceiverLocal.self)
    }
}
