//
//  UIKitPresenter.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/26/19.
//  Copyright © 2019 TT. All rights reserved.
//

import Foundation
import UIKit

open class UIKitPresenter: BasePresenter<UIViewController>, Presenter {
    public var presentationType: PresentationType { return .default }
    
    public func launch(view: UIViewController, from root: UIViewController, withLaunchStyle launchStyle:PresentationType = .default) {
        switch launchStyle {
        case .default:
            if let style = (view as? AnyFlowRepresentable)?.preferredLaunchStyle,
                style == .modally {
                root.present(view, animated: true)
            } else if let nav = root.navigationController {
                nav.pushViewController(view, animated: true)
            } else {
                root.present(view, animated: true)
            }
        case .modally:
            if let style = (view as? AnyFlowRepresentable)?.preferredLaunchStyle,
                style == .navigationStack {
                let nav = UINavigationController(rootViewController: view)
                root.present(nav, animated: true)
            } else {
                root.present(view, animated: true)
            }
        case .navigationStack:
            if let nav = root.navigationController {
                nav.pushViewController(view, animated: true)
            } else {
                let nav = UINavigationController(rootViewController: view)
                root.present(nav, animated: true)
            }
        }
    }
    
    public func abandon(_ workflow:Workflow, animated:Bool = true, onFinish:(() -> Void)? = nil) {
        guard let first = workflow.firstLoadedInstance?.value as? UIViewController else { return }
        if let nav = first.navigationController {
            if nav.viewControllers.first === first {
                nav.dismiss(animated: animated, completion: onFinish)
            } else {
                var farthestPresented = nav.presentedViewController
                while let presented = farthestPresented?.presentedViewController {
                    farthestPresented = presented
                }
                if let presented = farthestPresented {
                    presented.dismiss(animated: false, completion: onFinish)
                } else {
                    onFinish?()
                }
                nav.popToViewController(first, animated: false)
                nav.popViewController(animated: animated)
            }
        } else {
            first.dismiss(animated: animated, completion: onFinish)
        }
    }
}

public extension UIViewController {
    func launchInto(_ workflow:Workflow, args:Any? = nil, withLaunchStyle launchStyle:PresentationType = .default, onFinish:((Any?) -> Void)? = nil) {
        workflow.applyPresenter(UIKitPresenter())
        _ = workflow.launch(from: self, with: args, withLaunchStyle: launchStyle, onFinish: onFinish)?.value as? UIViewController
    }
}

public extension FlowRepresentable where Self: UIViewController {
    func abandonWorkflow() {
        workflow?.abandon()
    }
}
