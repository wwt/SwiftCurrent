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

    open var launchCalled = 0
    open var allTos = [AnyWorkflow.Element]()
    open var lastTo: AnyWorkflow.Element? {
        allTos.last
    }

    open func launch(to: AnyWorkflow.Element) {
        allTos.append(to)
        launchCalled += 1
    }

    open var proceedCalled = 0
    open var allFroms = [AnyWorkflow.Element]()
    open var lastFrom: AnyWorkflow.Element? {
        allFroms.last
    }

    open func proceed(to: AnyWorkflow.Element,
                      from: AnyWorkflow.Element) {
        allTos.append(to)
        allFroms.append(from)
        proceedCalled += 1
    }

    open var backUpCalled = 0
    open func backUp(from: AnyWorkflow.Element, to: AnyWorkflow.Element) {
        allFroms.append(from)
        allTos.append(to)
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
}
