//
//  UIKitPresenter.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/26/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import UIKit
import Workflow

/// An `OrchestrationResponder` that interacts with UIKit.
open class UIKitPresenter: OrchestrationResponder {
    let launchedFromVC: UIViewController
    let launchedPresentationType: LaunchStyle.PresentationType
    var firstLoadedInstance: UIViewController?

    /**
     Creates a `UIKitPresenter` that can respond to a `Workflow`'s actions.
     - Parameter viewController: the `UIViewController` that a `Workflow` should launch from.
     - Parameter launchStyle: the `LaunchStyle.PresentationType` to use to launch the `Workflow`.
     */
    public init(_ viewController: UIViewController, launchStyle: LaunchStyle.PresentationType) {
        launchedFromVC = viewController
        launchedPresentationType = launchStyle
    }

    /// Launches a `FlowRepresentable` that is also a `UIViewController`.
    public func launch(to: AnyWorkflow.Element) {
        guard let view = to.value.instance?.underlyingInstance as? UIViewController else { return }
        firstLoadedInstance = view
        displayInstance(to, style: launchedPresentationType.rawValue, view: view, root: launchedFromVC)
    }

    /// Proceeds in the `Workflow` by presenting the next `FlowRepresentable` that is also a `UIViewController`.
    public func proceed(to: AnyWorkflow.Element,
                        from: AnyWorkflow.Element) {
        guard let view = to.value.instance?.underlyingInstance as? UIViewController,
              let root = from.value.instance?.underlyingInstance as? UIViewController else { return }
        displayInstance(to, style: to.value.metadata.launchStyle, view: view, root: root) { [self] in
            if from.value.metadata.persistence == .removedAfterProceeding {
                destroy(root)
            }
        }
    }

    /// Back up in the `Workflow` by dismissing or popping the `FlowRepresentable` that is also a `UIViewController`.
    public func backUp(from: AnyWorkflow.Element,
                       to: AnyWorkflow.Element) {
        guard let view = to.value.instance?.underlyingInstance as? UIViewController else { return }
        if let nav = view.navigationController {
            nav.popToViewController(view, animated: true)
        } else if let presented = view.presentedViewController {
            presented.dismiss(animated: true)
        }
    }

    /// Abandons the `Workflow` by dismissing all `UIViewController`'s currently displayed by this presenter.
    public func abandon(_ workflow: AnyWorkflow, onFinish: (() -> Void)?) {
        abandon(workflow, animated: true, onFinish: onFinish)
    }

    func abandon(_ workflow: AnyWorkflow, animated: Bool, onFinish: (() -> Void)?) {
        guard let first = firstLoadedInstance else { return }
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
                $0 !== view
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

    private func displayInstance(_ to: AnyWorkflow.Element,
                                 style: LaunchStyle,
                                 view: UIViewController,
                                 root: UIViewController,
                                 completion: (() -> Void)? = nil) {
        let animated = to.value.metadata.persistence != .hiddenInitially
        switch LaunchStyle.PresentationType(rawValue: style) {
            case _ where style == .default:
                displayDefaultPresentationType(to: to, root: root, view: view, animated: animated, completion: completion)
            case .modal(let style):
                displayModalPresentationType(to: to, view: view, style: style, root: root, animated: animated, completion: completion)
            case .navigationStack:
                displayNavigationStackPresentationType(root: root, view: view, animated: animated, completion: completion)
            default: fatalError("UNKNOWN LAUNCH STYLE: \(style) PASSED TO \(Self.self)")
        }
    }

    private func displayDefaultPresentationType(to: AnyWorkflow.Element,
                                                root: UIViewController,
                                                view: UIViewController,
                                                animated: Bool,
                                                completion: (() -> Void)?) {
        if case .modal(let style) = LaunchStyle.PresentationType(rawValue: to.value.metadata.launchStyle) {
            if let modalPresentationStyle = UIModalPresentationStyle.styleFor(style) {
                view.modalPresentationStyle = modalPresentationStyle
            }
            root.present(view, animated: animated, completion: completion)
        } else if let nav = root.navigationController ?? root as? UINavigationController {
            nav.pushViewController(view, animated: animated)
            completion?()
        } else {
            root.present(view, animated: animated, completion: completion)
        }
    }

    private func displayModalPresentationType(to: AnyWorkflow.Element,
                                              view: UIViewController,
                                              style: (LaunchStyle.PresentationType.ModalPresentationStyle),
                                              root: UIViewController,
                                              animated: Bool,
                                              completion: (() -> Void)?) {
        if LaunchStyle.PresentationType(rawValue: to.value.metadata.launchStyle) == .navigationStack {
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
    }

    private func displayNavigationStackPresentationType(root: UIViewController,
                                                        view: UIViewController,
                                                        animated: Bool,
                                                        completion: (() -> Void)?) {
        if let nav = root.navigationController ?? root as? UINavigationController {
            nav.pushViewController(view, animated: animated)
            completion?()
        } else {
            let nav = UINavigationController(rootViewController: view)
            root.present(nav, animated: animated, completion: completion)
        }
    }
}
