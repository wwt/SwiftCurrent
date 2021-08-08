//  swiftlint:disable:this file_name
//  ViewControllerAdditions.swift
//  
//
//  Created by Tyler Thompson on 8/8/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import SwiftCurrent
extension UIViewController {
    private static var associatedKey = "_uiViewController_launchedWorkflows_assoc_key"
    var launchedWorkflows: [AnyWorkflow] {
        get {
            guard let value = objc_getAssociatedObject(self, &UIViewController.associatedKey) as? [AnyWorkflow] else {
                return []
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &UIViewController.associatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
#endif
