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

open class UIKitPresenter: AnyOrchestrationResponder {

    let launchedFromVC: UIViewController
    let launchedPresentationType: LaunchStyle.PresentationType

    init(_ viewController: UIViewController, launchStyle: LaunchStyle.PresentationType) {
        launchedFromVC = viewController
        launchedPresentationType = launchStyle
    }

    public func launch(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)) {
        guard let view = to.instance.value?.underlyingInstance as? UIViewController else { return }
        displayInstance(to, style: launchedPresentationType.rawValue, view: view, root: launchedFromVC)
    }

    public func abandon(_ workflow: AnyWorkflow, animated: Bool, onFinish: (() -> Void)?) {
        guard let first = workflow.firstLoadedInstance?.value?.underlyingInstance as? UIViewController else { return }
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
                                     style: LaunchStyle,
                                     view: UIViewController,
                                     root: UIViewController,
                                     completion: (() -> Void)? = nil) {
        let animated = !(to.metadata.persistance == .hiddenInitially)
        switch LaunchStyle.PresentationType(rawValue: style) {
            case _ where style == .default:
                if case .modal(let style) = LaunchStyle.PresentationType(rawValue: to.metadata.launchStyle) {
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
                if LaunchStyle.PresentationType(rawValue: to.metadata.launchStyle) == .navigationStack {
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
            default: fatalError("UNKNOWN LAUNCH STYLE: \(style) PASSED TO \(Self.self)")
        }
    }

    public func proceed(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData),
                        from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)) {
        guard let view = to.instance.value?.underlyingInstance as? UIViewController,
              let root = from.instance.value?.underlyingInstance as? UIViewController else { return }
        displayInstance(to, style: to.metadata.launchStyle, view: view, root: root) { [self] in
            if from.metadata.persistance == .removedAfterProceeding {
                destroy(root)
            }
        }
    }

    public func proceedBackward(from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData),
                                to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)) {

    }
}
