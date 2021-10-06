//
//  NotificationReceiverLocal.swift
//  SwiftCurrent
//
//  Created by Richard Gist on 10/1/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftCurrent

protocol WorkflowTestingReceiver {
    static var workflowLaunchedData: [WorkflowTestingData] { get set }
}

class NotificationReceiverLocal: NSObject {
    private static var receivers = [WorkflowTestingReceiver.Type]()

    @objc static func workflowLaunched(notification: Notification) {
        guard let dict = notification.object as? [String: Any?],
              let testData = WorkflowTestingData(from: dict) else {
            fatalError("WorkflowLaunched notification has incorrect format, this may be because you need to update SwiftCurrent_Testing")
        }

        receivers.forEach { $0.workflowLaunchedData.append(testData) }
    }


    static func register(on notificationCenter: NotificationCenter, for receiver: WorkflowTestingReceiver.Type) {
        notificationCenter.addObserver(Self.self,
                                       selector: #selector(Self.workflowLaunched(notification:)),
                                       name: .workflowLaunched,
                                       object: nil)
        receivers.append(receiver)
    }

    static func unregister(on notificationCenter: NotificationCenter, for receiver: WorkflowTestingReceiver.Type) {
        notificationCenter.removeObserver(Self.self)
        receivers.removeAll { $0 == receiver.self }
    }
}
