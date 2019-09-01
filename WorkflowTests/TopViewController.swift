//
//  TopViewController.swift
//  WorkflowTests
//
//  Created by Tyler Thompson on 8/26/19.
//  Copyright © 2019 Tyler Tompson. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    static func topViewController(of controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
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
