//
//  TopViewController.swift
//  WorkflowTests
//
//  Created by Tyler Thompson on 8/26/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    static var rootViewController: UIViewController? {
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first?.windows.first?.rootViewController
    }

    static func topViewController(of controller: UIViewController? = rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController,
            let visible = navigationController.visibleViewController {
            return topViewController(of: visible)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(of: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(of: presented)
        }
        return controller
    }
}
