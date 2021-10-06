//
//  WorkflowTestingData.swift
//  SwiftCurrent
//
//  Created by Richard Gist on 10/1/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftCurrent

public struct WorkflowTestingData {
    public var workflow: AnyWorkflow
    public var orchestrationResponder: OrchestrationResponder
    public var args: AnyWorkflow.PassedArgs
    public var style: LaunchStyle
    public var onFinish: ((AnyWorkflow.PassedArgs) -> Void)?

    public init?(from dict: [String: Any?]) {
        guard let workflow = dict["workflow"] as? AnyWorkflow,
              let style = dict["style"] as? LaunchStyle,
              let responder = dict["responder"] as? OrchestrationResponder,
              let args = dict["args"] as? AnyWorkflow.PassedArgs,
              let onFinish = dict["onFinish"] as? ((AnyWorkflow.PassedArgs) -> Void)? else {
            return nil
        }

        self.workflow = workflow
        self.orchestrationResponder = responder
        self.args = args
        self.style = style
        self.onFinish = onFinish
    }
}
