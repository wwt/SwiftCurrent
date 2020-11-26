//
//  UIKitPresenter.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/26/19.
//  Copyright © 2019 Tyler Tompson. All rights reserved.
//

import Foundation
import UIKit
import Workflow

extension NSObject {
    func copyObject<T: NSObject>() throws -> T? {
        let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? T
    }
}

public extension FlowPersistance {
    static let hiddenInitially = FlowPersistance.persistWhenSkipped
}

extension UIModalPresentationStyle {
    static func styleFor(_ style: PresentationType.ModalPresentationStyle) -> UIModalPresentationStyle? {
        switch style {
            case .fullScreen: return .fullScreen
            case .pageSheet: return .pageSheet
            case .formSheet: return .formSheet
            case .currentContext: return .currentContext
            case .custom: return .custom
            case .overFullScreen: return .overFullScreen
            case .overCurrentContext: return .overCurrentContext
            case .popover: return .popover
            case .automatic: if #available(iOS 13.0, *) {
                return .automatic
            }
            default: return nil
        }
        return nil
    }
}

open class UIKitPresenter: AnyOrchestrationResponder {
    let launchedFromVC: UIViewController
    let launchedPresentationType: PresentationType

    init(_ viewController: UIViewController, launchStyle: PresentationType) {
        launchedFromVC = viewController
        launchedPresentationType = launchStyle
    }

    public func launch(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)) {
        guard let view = to.instance.value as? UIViewController else { return }
        displayInstance(to, style: launchedPresentationType, view: view, root: launchedFromVC)
    }

    public func abandon(_ workflow: AnyWorkflow, animated: Bool, onFinish: (() -> Void)?) {
        guard let first = workflow.firstLoadedInstance?.value as? UIViewController else { return }
        if let nav = first.navigationController {
            if nav.viewControllers.first === first {
                if let presenting = nav.presentingViewController {
                    presenting.dismiss(animated: animated, completion: onFinish)
                } else {
                    nav.setViewControllers([], animated: animated)
                    onFinish?()
                }
            } else {
                if nav.presentedViewController != nil {
                    nav.dismiss(animated: animated) {
                        onFinish?()
                        nav.popToViewController(first, animated: false)
                        nav.popViewController(animated: animated)
                    }
                } else {
                    onFinish?()
                    nav.popToViewController(first, animated: false)
                    nav.popViewController(animated: animated)
                }
            }
        } else {
            first.dismiss(animated: animated, completion: onFinish)
        }
    }

    private func destroy(_ view: UIViewController) {
        if let nav = view.navigationController {
            let vcs = nav.viewControllers.filter {
                return $0 !== view
            }
            nav.setViewControllers(vcs, animated: false)
        } else {
            let parent = view.presentingViewController
            let child = view.presentedViewController
            if let cv: UIView = try? child?.view.copyObject() {
                view.view = cv
            }
            parent?.dismiss(animated: false) {
                if let p = parent,
                    let c = child {
                    p.present(c, animated: false)
                }
            }
        }
    }

    fileprivate func displayInstance(_ to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData),
                                     style: PresentationType,
                                     view: UIViewController,
                                     root: UIViewController,
                                     completion: (() -> Void)? = nil) {
        let animated = !(to.metadata.persistance == .hiddenInitially)
        switch style {
            case .default:
                if case .modal(let style) = to.metadata.presentationType {
                    if let modalPresentationStyle = UIModalPresentationStyle.styleFor(style) {
                        view.modalPresentationStyle = modalPresentationStyle
                    }
                    root.present(view, animated: animated, completion: completion)
                } else if let nav = root.navigationController
                            ?? root as? UINavigationController {
                    nav.pushViewController(view, animated: animated)
                    completion?()
                } else {
                    root.present(view, animated: animated, completion: completion)
                }
            case .modal(let style):
                if to.metadata.presentationType == .navigationStack {
                    let nav = UINavigationController(rootViewController: view)
                    if let modalPresentationStyle = UIModalPresentationStyle.styleFor(style) {
                        nav.modalPresentationStyle = modalPresentationStyle
                    }
                    root.present(nav, animated: animated, completion: completion)
                } else {
                    if let modalPresentationStyle = UIModalPresentationStyle.styleFor(style) {
                        view.modalPresentationStyle = modalPresentationStyle
                    }
                    root.present(view, animated: animated, completion: completion)
                }
            case .navigationStack:
                if let nav = root.navigationController
                    ?? root as? UINavigationController {
                    nav.pushViewController(view, animated: animated)
                    completion?()
                } else {
                    let nav = UINavigationController(rootViewController: view)
                    root.present(nav, animated: animated, completion: completion)
                }
        }
    }

    public func proceed(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData),
                        from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)) {
        guard let view = to.instance.value as? UIViewController,
              let root = from.instance.value as? UIViewController else { return }
        let completion = { [self] in
            if from.metadata.persistance == .removedAfterProceeding {
                destroy(root)
            }
        }
        displayInstance(to, style: to.metadata.presentationType, view: view, root: root, completion: completion)
    }

}

public extension UIViewController {
    ///launchInto: When using UIKit this is how you launch a workflow
    /// - Parameter workflow: `Workflow` to launch
    /// - Parameter args: Args to pass to the first `FlowRepresentable`
    /// - Parameter launchStyle: The `PresentationType` used to launch the workflow
    /// - Parameter onFinish: A callback that is called when the last item in the workflow calls back
    /// - Note: In the background this applies a UIKitPresenter, if you call launch on workflow directly you'll need to apply one yourself
    func launchInto(_ workflow: AnyWorkflow, args: Any? = nil, withLaunchStyle launchStyle: PresentationType = .default, onFinish: ((Any?) -> Void)? = nil) {
        workflow.applyOrchestrationResponder(UIKitPresenter(self, launchStyle: launchStyle))
        _ = workflow.launch(with: args,
                            withLaunchStyle: launchStyle,
                            onFinish: onFinish)?.value as? UIViewController
        #if DEBUG
        if NSClassFromString("XCTest") != nil {
            NotificationCenter.default.post(name: .workflowLaunched, object: [
                "workflow": workflow,
                "launchFrom": self,
                "args": args,
                "style": launchStyle,
                "onFinish": onFinish
            ])
        }
        #endif
    }
}

public extension FlowRepresentable where Self: UIViewController {
    func abandonWorkflow() {
        workflow?.abandon()
    }
}
