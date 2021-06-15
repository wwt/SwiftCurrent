//
//  WorkflowTests.swift
//  
//
//  Created by Tyler Thompson on 5/1/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import SwiftCurrent

class WorkflowTests: XCTestCase {
    func testFlowRepresentablesWithMultipleTypesCanBeStoredAndRetrieved() {
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = Int
            static var shouldLoadCalledOnFR1 = false

            weak var _workflowPointer: AnyFlowRepresentable?

            init(with args: String) { }

            func shouldLoad() -> Bool {
                FR1.shouldLoadCalledOnFR1 = true
                return true
            }
        }
        struct FR2: FlowRepresentable {
            static var shouldLoadCalledOnFR2 = false

            weak var _workflowPointer: AnyFlowRepresentable?

            init(with args: Int) { }

            func shouldLoad() -> Bool {
                FR2.shouldLoadCalledOnFR2 = true
                return true
            }
        }
        let flow = Workflow(FR1.self).thenProceed(with: FR2.self)
        _ = flow.first?.value.metadata.flowRepresentableFactory(.args("str")).shouldLoad()
        _ = flow.last?.value.metadata.flowRepresentableFactory(.args(1)).shouldLoad()

        XCTAssert(FR1.shouldLoadCalledOnFR1, "Should load not called on flow representable 1 with correct corresponding type")
        XCTAssert(FR2.shouldLoadCalledOnFR2, "Should load not called on flow representable 2 with correct corresponding type")
    }

    func testFlowRepresentablesThatDefineAWorkflowInputOfOptionalAnyDoesNotRecurseForever() {
        class FR1: FlowRepresentable {
            static var shouldLoadCalledOnFR1 = false

            weak var _workflowPointer: AnyFlowRepresentable?

            required init(with args: Any?) { }
        }

        let instance = AnyFlowRepresentable(FR1.self, args: .args("str"))
        XCTAssert(instance.shouldLoad() == true)
    }

    func testAnyFlowRepresentableThrowsFatalErrorIfItSomehowHasATypeMismatch() {
        class FR1: TestFlowRepresentable<String, Int>, FlowRepresentable {
            required init(with args: String) { }
        }

        XCTAssertThrowsFatalError {
            _ = AnyFlowRepresentable(FR1.self, args: .args(12.34))
        }
    }

    func testFlowRepresentableThrowsFatalErrorIfNoCustomEmptyInitSupplied() {
        class FR1: FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?

            required init(with name:String) { }
        }

        XCTAssertThrowsFatalError {
            _ = FR1()
        }
    }
}

extension WorkflowTests {
    class TestFlowRepresentable<I, O> {
        typealias WorkflowInput = I
        typealias WorkflowOutput = O

        weak var _workflowPointer: AnyFlowRepresentable?
    }
}

