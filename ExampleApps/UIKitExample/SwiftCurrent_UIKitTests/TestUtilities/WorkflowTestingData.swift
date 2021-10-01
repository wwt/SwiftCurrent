//
//  WorkflowTestingData.swift
//  SwiftCurrent
//
//  Created by Richard Gist on 10/1/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftCurrent

struct WorkflowTestingData {
    var workflow: AnyWorkflow
    var orchestrationResponder: OrchestrationResponder
    var args: AnyWorkflow.PassedArgs
    var style: LaunchStyle
    var onFinish: ((AnyWorkflow.PassedArgs) -> Void)?
}
