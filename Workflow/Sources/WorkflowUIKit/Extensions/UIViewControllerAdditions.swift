//  swiftlint:disable:this file_name
//  Reason: The file name reflects the contents of the file.
//
//  UIViewControllerAdditions.swift
//  
//
//  Created by Tyler Thompson on 11/26/20.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import UIKit
import Workflow

extension UIViewController {
    /**
    When using UIKit this is how you launch a workflow
    - Parameter workflow: `Workflow` to launch
    - Parameter args: Args to pass to the first `FlowRepresentable`
    - Parameter launchStyle: The `PresentationType` used to launch the workflow
    - Parameter onFinish: A callback that is called when the last item in the workflow proceeds; called with the `AnyWorkflow.PassedArgs` the workflow finished with.
    - Note: In the background this applies a UIKitPresenter, if you call launch on workflow directly you'll need to apply one yourself
    */
    public func launchInto(_ workflow: AnyWorkflow,
                           args: Any? = nil,
                           withLaunchStyle launchStyle: LaunchStyle.PresentationType = .default,
                           onFinish: ((AnyWorkflow.PassedArgs) -> Void)? = nil) {
        workflow.applyOrchestrationResponder(UIKitPresenter(self, launchStyle: launchStyle))
        workflow.launch(with: args,
                        withLaunchStyle: launchStyle.rawValue,
                        onFinish: onFinish)
        #if canImport(XCTest)
        NotificationCenter.default.post(name: .workflowLaunched, object: [
            "workflow": workflow,
            "launchFrom": self,
            "args": args,
            "style": launchStyle,
            "onFinish": onFinish
        ])
        #endif
    }

    /**
    When using UIKit this is how you launch a workflow
    - Parameter workflow: `Workflow` to launch
    - Parameter launchStyle: The `PresentationType` used to launch the workflow
    - Parameter onFinish: A callback that is called when the last item in the workflow proceeds; called with the `AnyWorkflow.PassedArgs` the workflow finished with.
    - Note: In the background this applies a UIKitPresenter, if you call launch on workflow directly you'll need to apply one yourself
    */
    public func launchInto(_ workflow: AnyWorkflow,
                           withLaunchStyle launchStyle: LaunchStyle.PresentationType = .default,
                           onFinish: ((AnyWorkflow.PassedArgs) -> Void)? = nil) {
        workflow.applyOrchestrationResponder(UIKitPresenter(self, launchStyle: launchStyle))
        workflow.launch(withLaunchStyle: launchStyle.rawValue,
                        onFinish: onFinish)
        #if canImport(XCTest)
        NotificationCenter.default.post(name: .workflowLaunched, object: [
            "workflow": workflow,
            "launchFrom": self,
            "style": launchStyle,
            "onFinish": onFinish as Any
        ])
        #endif
    }
}

extension FlowRepresentable where Self: UIViewController {
    /**
     Called when the current workflow should be terminated, and the app should return to the point before the workflow was launched
     - Parameter animated: A boolean indicating whether abandoning the workflow should be animated
     - Parameter onFinish: A callback after the workflow has been abandoned.
     - Note: In order to dismiss UIKit views the workflow must have an `OrchestrationResponder` that is a `UIKitPresenter`.
     */
    public func abandonWorkflow(animated: Bool = true, onFinish:(() -> Void)? = nil) {
        workflow?.abandon(animated: animated, onFinish: onFinish)
    }
}
