//
//  MockOrchestrationResponder.swift
//  UIKitExampleTests
//
//  Created by Tyler Thompson on 10/5/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import SwiftCurrent

class MockOrchestrationResponder: OrchestrationResponder {
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

    var launchCalled = 0
    var lastTo: AnyWorkflow.Element?
    func launch(to: AnyWorkflow.Element) {
        lastTo = to
        launchCalled += 1
    }

    var proceedCalled = 0
    var lastFrom: AnyWorkflow.Element?
    var lastCompletion:(() -> Void)?
    func proceed(to: AnyWorkflow.Element,
                 from: AnyWorkflow.Element) {
        lastTo = to
        lastFrom = from
        proceedCalled += 1
    }

    var backUpCalled = 0
    func backUp(from: AnyWorkflow.Element, to: AnyWorkflow.Element) {
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
