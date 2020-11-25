//
//  WorkflowNotifications.swift
//  Workflow
//
//  Created by Tyler Thompson on 9/25/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation

#if DEBUG
extension Notification.Name {
    static var workflowLaunched: Notification.Name {
        return Notification.Name(rawValue: "WorkflowLaunched")
    }
}
#endif
