//
//  WorkflowSwiftUIAdditions.swift
//  
//
//  Created by Morgan Zellers on 6/22/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import Foundation
import SwiftCurrent

extension Workflow {
    /**
     Called when the workflow should be terminated, and the app should return to the point before the workflow was launched.
     - Parameter animated: a boolean indicating whether abandoning the workflow should be animated.
     - Parameter onFinish: a callback after the workflow has been abandoned.
     - Important: In order to dismiss UIKit views the workflow must have an `OrchestrationResponder` that is a `UIKitPresenter`.
     */
    public func abandon(animated: Bool = true, onFinish:(() -> Void)? = nil) {
        AnyWorkflow(self).abandon(animated: animated, onFinish: onFinish)
    }
}

extension AnyWorkflow {
    /**
     Called when the workflow should be terminated, and the app should return to the point before the workflow was launched.
     - Parameter animated: a boolean indicating whether abandoning the workflow should be animated.
     - Parameter onFinish: a callback after the workflow has been abandoned.
     - Important: In order to dismiss UIKit views the workflow must have an `OrchestrationResponder` that is a `UIKitPresenter`.
     */
    public func abandon(animated: Bool = true, onFinish:(() -> Void)? = nil) {
        if let presenter = orchestrationResponder as? SwiftUIResponder2 {
            presenter.abandon(self) { [weak self] in
                self?._abandon()
                onFinish?()
            }
        } else if let responder = orchestrationResponder {
            responder.abandon(self) { [weak self] in
                self?._abandon()
                onFinish?()
            }
        } else {
            _abandon()
        }
    }
}
