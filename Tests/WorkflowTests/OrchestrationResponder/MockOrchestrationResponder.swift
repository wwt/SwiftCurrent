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
    var allTos = [AnyWorkflow.Element]()
    var lastTo: AnyWorkflow.Element? {
        allTos.last
    }

    func launch(to: AnyWorkflow.Element) {
        allTos.append(to)
        launchCalled += 1
    }

    var proceedCalled = 0
    var allFroms = [AnyWorkflow.Element]()
    var lastFrom: AnyWorkflow.Element? {
        allFroms.last
    }

    func proceed(to: AnyWorkflow.Element,
                 from: AnyWorkflow.Element) {
        allTos.append(to)
        allFroms.append(from)
        proceedCalled += 1
    }

    var backUpCalled = 0
    func backUp(from: AnyWorkflow.Element, to: AnyWorkflow.Element) {
        allFroms.append(from)
        allTos.append(to)
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

    var completeCalled = 0
    var lastPassedArgs: AnyWorkflow.PassedArgs?
    var lastCompleteOnFinish: ((AnyWorkflow.PassedArgs) -> Void)?
    var complete_EnableDefaultImplementation = false
    func complete(_ workflow: AnyWorkflow, passedArgs: AnyWorkflow.PassedArgs, onFinish: ((AnyWorkflow.PassedArgs) -> Void)?) {
        lastWorkflow = workflow
        lastPassedArgs = passedArgs
        lastCompleteOnFinish = onFinish
        completeCalled += 1

        if complete_EnableDefaultImplementation { onFinish?(passedArgs) }
    }
}
