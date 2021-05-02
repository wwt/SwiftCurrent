//
//  WorkflowTests.swift
//  
//
//  Created by Tyler Thompson on 5/1/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import Workflow

class WorkflowTests: XCTestCase {
    func testFlowRepresentablesWithMultipleTypesCanBeStoredAndRetreived() {
        struct FR1: FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?

            static var shouldLoadCalledOnFR1 = false
            typealias WorkflowInput = String
            typealias WorkflowOutput = Int

            static func instance() -> Self { Self() }

            func shouldLoad(with args: String) -> Bool {
                FR1.shouldLoadCalledOnFR1 = true
                return true
            }
        }
        struct FR2: FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?

            static var shouldLoadCalledOnFR2 = false
            typealias WorkflowInput = Int

            static func instance() -> Self { Self() }

            func shouldLoad(with args: Int) -> Bool {
                FR2.shouldLoadCalledOnFR2 = true
                return true
            }
        }
        let flow = Workflow(FR1.self).thenPresent(FR2.self)
        let first = flow.first?.value.flowRepresentableFactory()
        let last = flow.last?.value.flowRepresentableFactory()
        _ = first?.shouldLoad(with: "str")
        _ = last?.shouldLoad(with: 1)

        XCTAssert(FR1.shouldLoadCalledOnFR1, "Should load not called on flow representable 1 with correct corresponding type")
        XCTAssert(FR2.shouldLoadCalledOnFR2, "Should load not called on flow representable 2 with correct corresponding type")
    }

    func testFlowRepresentablesThatDefineAWorkflowInputOfOptionalAnyDoesNotRecurseForever() {
        class FR1: FlowRepresentable {
            func shouldLoad(with args: Any?) -> Bool { true }

            weak var _workflowPointer: AnyFlowRepresentable?

            static var shouldLoadCalledOnFR1 = false
            typealias WorkflowInput = Any?

            static func instance() -> Self { FR1() as! Self }
        }

        var fr1 = FR1.instance()
        let instance = AnyFlowRepresentable(&fr1)
        XCTAssert(instance.shouldLoad(with: "str") == true)
    }

    func testAnyFlowRepresentableThrowsFatalErrorIfItSomehowHasATypeMismatch() {
        class FR1: TestFlowRepresentable<String, Int>, FlowRepresentable {
            func shouldLoad(with args: String) -> Bool { true }
        }

        var instance = FR1()
        let rep = AnyFlowRepresentable(&instance)

        XCTAssertThrowsFatalError {
            _ = rep.shouldLoad(with: 10.23)
        }
    }
}

extension WorkflowTests {
    class TestFlowRepresentable<I, O> {
        typealias WorkflowInput = I
        typealias WorkflowOutput = O

        required init() { }

        static func instance() -> Self { Self() }

        weak var _workflowPointer: AnyFlowRepresentable?
    }
}

