//
//  MockOrchestrationResponder.swift
//  
//
//  Created by Tyler Thompson on 11/25/20.
//

import Foundation
import Workflow

class MockOrchestrationResponder: OrchestrationResponder {
    var launchCalled = 0
    var lastTo: AnyWorkflow.InstanceNode?
    func launch(to: AnyWorkflow.InstanceNode) {
        lastTo = to
        launchCalled += 1
    }

    var proceedCalled = 0
    var lastFrom: AnyWorkflow.InstanceNode?
    var lastCompletion:(() -> Void)?
    func proceed(to: AnyWorkflow.InstanceNode,
                 from: AnyWorkflow.InstanceNode) {
        lastTo = to
        lastFrom = from
        proceedCalled += 1
    }

    var backUpCalled = 0
    func backUp(from: AnyWorkflow.InstanceNode, to: AnyWorkflow.InstanceNode) {
        lastFrom = from
        lastTo = to
        backUpCalled += 1
    }

    var abandonCalled = 0
    var lastWorkflow: AnyWorkflow?
    var lastOnFinish:(() -> Void)?
    func abandon(_ workflow: AnyWorkflow, onFinish: (() -> Void)?) {
        lastWorkflow = workflow
        lastOnFinish = onFinish
        abandonCalled += 1
    }
}
