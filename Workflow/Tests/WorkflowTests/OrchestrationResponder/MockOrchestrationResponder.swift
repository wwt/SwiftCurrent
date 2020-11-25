//
//  MockOrchestrationResponder.swift
//  
//
//  Created by Tyler Thompson on 11/25/20.
//

import Foundation
import Workflow

class MockOrchestrationResponder: AnyOrchestrationResponder {
    var proceedCalled = 0
    var lastTo: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)?
    var lastFrom: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)?
    var lastCompletion:(() -> Void)?
    func proceed(to: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData), from: (instance: AnyWorkflow.InstanceNode, metadata: FlowRepresentableMetaData)?) {
        lastTo = to
        lastFrom = from
        proceedCalled += 1
    }

}
