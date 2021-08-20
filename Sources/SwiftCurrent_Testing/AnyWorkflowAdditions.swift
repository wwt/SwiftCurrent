//  swiftlint:disable:this file_name
//  AnyWorkflowAdditions.swift
//  
//
//  Created by Tyler Thompson on 8/8/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import SwiftCurrent
extension AnyWorkflow {
    private static var launchStyleAssociatedKey = "_anyWorkflow_launchStyle_assoc_key"
    /// The style used to launch this `Workflow`.
    public var launchStyle: LaunchStyle {
        get {
            guard let value = objc_getAssociatedObject(self, &Self.launchStyleAssociatedKey) as? LaunchStyle else {
                return .default
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &Self.launchStyleAssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private static var onFinishAssociatedKey = "_anyWorkflow_onFinish_assoc_key"
    /// The onFinish block used when launching this `Workflow`.
    public var onFinish: ((AnyWorkflow.PassedArgs) -> Void)? {
        get {
            guard let value = objc_getAssociatedObject(self, &Self.onFinishAssociatedKey) as? ((AnyWorkflow.PassedArgs) -> Void)? else {
                return nil
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &Self.onFinishAssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
