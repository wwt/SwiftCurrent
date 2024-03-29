//
//  Launcher.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Tyler Thompson on 8/21/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI
import SwiftCurrent

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class Launcher: ObservableObject {
    var workflow: AnyWorkflow
    var launchArgs: AnyWorkflow.PassedArgs
    init(workflow: AnyWorkflow,
         responder: OrchestrationResponder,
         launchArgs: AnyWorkflow.PassedArgs) {
        self.workflow = workflow
        self.launchArgs = launchArgs
        if workflow.orchestrationResponder == nil {
            workflow.launch(withOrchestrationResponder: responder, passedArgs: launchArgs)
        }
    }
}
