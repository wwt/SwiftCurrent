//
//  MockOrchestrationResponder.swift
//  SwiftCurrent_Testing
//
//  Created by Tyler Thompson on 10/5/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import SwiftCurrent

open class MockOrchestrationResponder: OrchestrationResponder {
    public init() { }

    open var completeCalled = 0
    open var lastPassedArgs: AnyWorkflow.PassedArgs?
    open var lastCompleteOnFinish: ((AnyWorkflow.PassedArgs) -> Void)?
    open var complete_EnableDefaultImplementation = false
    open func complete(_ workflow: AnyWorkflow, passedArgs: AnyWorkflow.PassedArgs, onFinish: ((AnyWorkflow.PassedArgs) -> Void)?) {
        lastWorkflow = workflow
        lastPassedArgs = passedArgs
        lastCompleteOnFinish = onFinish
        completeCalled += 1

        if complete_EnableDefaultImplementation { onFinish?(passedArgs) }
    }

    open var launchCalled = 0
    open var lastTo: AnyWorkflow.Element?
    open func launch(to: AnyWorkflow.Element) {
        lastTo = to
        launchCalled += 1
    }

    open var proceedCalled = 0
    open var lastFrom: AnyWorkflow.Element?
    open var lastCompletion:(() -> Void)?
    open func proceed(to: AnyWorkflow.Element,
                      from: AnyWorkflow.Element) {
        lastTo = to
        lastFrom = from
        proceedCalled += 1
    }

    open var backUpCalled = 0
    open func backUp(from: AnyWorkflow.Element, to: AnyWorkflow.Element) {
        lastFrom = from
        lastTo = to
        backUpCalled += 1
    }

    open var abandonCalled = 0
    open var lastWorkflow: AnyWorkflow?
    open var lastOnFinish:(() -> Void)?
    open func abandon(_ workflow: AnyWorkflow, onFinish: (() -> Void)?) {
        lastWorkflow = workflow
        lastOnFinish = onFinish
        abandonCalled += 1
    }
}
