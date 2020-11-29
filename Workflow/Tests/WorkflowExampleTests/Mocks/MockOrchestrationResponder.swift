//
//  MockOrchestrationResponder.swift
//  WorkflowExampleTests
//
//  Created by Tyler Thompson on 10/5/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import Workflow

class MockOrchestrationResponder: AnyOrchestrationResponder {
    var launchCalled = 0
    var lastTo: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)?
    func launch(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)) {
        lastTo = to
        launchCalled += 1
    }

    var proceedCalled = 0
    var lastFrom: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)?
    var lastCompletion:(() -> Void)?
    func proceed(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData),
                 from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)) {
        lastTo = to
        lastFrom = from
        proceedCalled += 1
    }

    var proceedBackwardCalled = 0
    func proceedBackward(from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData), to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)) {
        lastFrom = from
        lastTo = to
        proceedBackwardCalled += 1
    }


    var abandonCalled = 0
    var lastWorkflow:AnyWorkflow?
    var lastOnFinish:(() -> Void)?
    func abandon(_ workflow: AnyWorkflow, animated: Bool, onFinish: (() -> Void)?) {
        lastWorkflow = workflow
        lastOnFinish = onFinish
        abandonCalled += 1
    }
}
