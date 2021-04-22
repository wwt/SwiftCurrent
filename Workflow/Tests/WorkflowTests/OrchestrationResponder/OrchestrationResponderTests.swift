//
//  OrchestrationResponderTests.swift
//  
//
//  Created by Tyler Thompson on 11/24/20.
//

import Foundation
import XCTest

import Workflow

class OrchestrationResponderTests: XCTestCase {
    func testWorkflowCanProceedForwardThroughFlow() {
        class FR1: TestPassthroughFlowRepresentable { }
        class FR2: TestPassthroughFlowRepresentable { }
        class FR3: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)
        let responder = MockOrchestrationResponder()
        wf.applyOrchestrationResponder(responder)

        let launchedRepresentable = wf.launch()

        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value?.underlyingInstance is FR1)
        XCTAssert(responder.lastTo?.instance.value?.underlyingInstance is FR1)
        XCTAssertNil(responder.lastFrom)

        (launchedRepresentable?.value?.underlyingInstance as? FR1)?.proceedInWorkflow()

        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert(responder.lastTo?.instance.value?.underlyingInstance is FR2)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.instance.value?.underlyingInstance is FR1)
        XCTAssert((responder.lastFrom?.instance.value?.underlyingInstance as? FR1) === (launchedRepresentable?.value?.underlyingInstance as? FR1))

        let fr2 = (responder.lastTo?.instance.value?.underlyingInstance as? FR2)
        fr2?.proceedInWorkflow()

        XCTAssertEqual(responder.proceedCalled, 2)
        XCTAssert(responder.lastTo?.instance.value?.underlyingInstance is FR3)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.instance.value?.underlyingInstance is FR2)
        XCTAssert((responder.lastFrom?.instance.value?.underlyingInstance as? FR2) === fr2)
    }

    func testWorkflowCallsOnFinishWhenItIsDone() {
        class FR1: TestPassthroughFlowRepresentable { }
        class FR2: TestPassthroughFlowRepresentable { }
        class FR3: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)
        let responder = MockOrchestrationResponder()
        wf.applyOrchestrationResponder(responder)
        let expectation = self.expectation(description: "OnFinish called")

        let launchedRepresentable = wf.launch { _ in expectation.fulfill() }

        (launchedRepresentable?.value?.underlyingInstance as? FR1)?.proceedInWorkflow()
        (responder.lastTo?.instance.value?.underlyingInstance as? FR2)?.proceedInWorkflow()
        (responder.lastTo?.instance.value?.underlyingInstance as? FR3)?.proceedInWorkflow()

        wait(for: [expectation], timeout: 3)
    }

    func testWorkflowCallsOnFinishWhenItIsDone_andPassesForwardLastArguments() {
        class Object { }
        let val = Object()
        class FR1: TestPassthroughFlowRepresentable { }
        class FR2: TestPassthroughFlowRepresentable { }
        class FR3: TestFlowRepresentable<Never, Object>, FlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)
        let responder = MockOrchestrationResponder()
        wf.applyOrchestrationResponder(responder)
        let expectation = self.expectation(description: "OnFinish called")

        let launchedRepresentable = wf.launch { args in
            XCTAssert(args as? Object === val)
            expectation.fulfill()
        }

        (launchedRepresentable?.value?.underlyingInstance as? FR1)?.proceedInWorkflow()
        (responder.lastTo?.instance.value?.underlyingInstance as? FR2)?.proceedInWorkflow()
        (responder.lastTo?.instance.value?.underlyingInstance as? FR3)?.proceedInWorkflow(val)

        wait(for: [expectation], timeout: 3)
    }

    func testWorkflowCanProceedForwardAndBackwardThroughFlow() {
        class FR1: TestPassthroughFlowRepresentable { }
        class FR2: TestPassthroughFlowRepresentable { }
        class FR3: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)
        let responder = MockOrchestrationResponder()
        wf.applyOrchestrationResponder(responder)

        let launchedRepresentable = wf.launch()

        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value?.underlyingInstance is FR1)
        XCTAssert(responder.lastTo?.instance.value?.underlyingInstance is FR1)
        XCTAssertNil(responder.lastFrom)

        (launchedRepresentable?.value?.underlyingInstance as? FR1)?.proceedInWorkflow()

        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert(responder.lastTo?.instance.value?.underlyingInstance is FR2)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.instance.value?.underlyingInstance is FR1)
        XCTAssert((responder.lastFrom?.instance.value?.underlyingInstance as? FR1) === (launchedRepresentable?.value?.underlyingInstance as? FR1))

        let fr2 = (responder.lastTo?.instance.value?.underlyingInstance as? FR2)
        fr2?.proceedBackwardInWorkflow()
        XCTAssertEqual(responder.proceedBackwardCalled, 1)
        XCTAssert(responder.lastTo?.instance.value?.underlyingInstance is FR1)
        XCTAssertNotNil(responder.lastTo)
        XCTAssert(responder.lastTo?.instance.value?.underlyingInstance is FR1)
        XCTAssert((responder.lastTo?.instance.value?.underlyingInstance as? FR1) === (launchedRepresentable?.value?.underlyingInstance as? FR1))

        fr2?.proceedInWorkflow()

        XCTAssertEqual(responder.proceedCalled, 2)
        XCTAssert(responder.lastTo?.instance.value?.underlyingInstance is FR3)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.instance.value?.underlyingInstance is FR2)
        XCTAssert((responder.lastFrom?.instance.value?.underlyingInstance as? FR2) === fr2)
    }

    func testWorkflowCallsOnFinishWhenItIsDone_EvenWhenMovingBackwardsForABit() {
        class FR1: TestPassthroughFlowRepresentable { }
        class FR2: TestPassthroughFlowRepresentable { }
        class FR3: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)
        let responder = MockOrchestrationResponder()
        wf.applyOrchestrationResponder(responder)
        let expectation = self.expectation(description: "OnFinish called")

        let launchedRepresentable = wf.launch { _ in expectation.fulfill() }

        (launchedRepresentable?.value?.underlyingInstance as? FR1)?.proceedInWorkflow()
        (responder.lastTo?.instance.value?.underlyingInstance as? FR2)?.proceedInWorkflow()
        (responder.lastTo?.instance.value?.underlyingInstance as? FR2)?.proceedBackwardInWorkflow()
        (responder.lastTo?.instance.value?.underlyingInstance as? FR1)?.proceedInWorkflow()
        (responder.lastTo?.instance.value?.underlyingInstance as? FR2)?.proceedInWorkflow()
        (responder.lastTo?.instance.value?.underlyingInstance as? FR3)?.proceedInWorkflow()

        wait(for: [expectation], timeout: 3)
    }

    func testWorkflowCallsOnFinishWhenItIsDone_andPassesForwardInitialArguments_EvenWhenMovingBackwardsForABit() {
        class Object { }
        let val = Object()
        class FR1: TestFlowRepresentable<Object, Object>, FlowRepresentable {
            var obj: Object!
            func shouldLoad(with args: Object) -> Bool {
                obj = args
                return true
            }
        }
        class FR2: TestFlowRepresentable<Object, Object>, FlowRepresentable {
            var obj: Object!
            func shouldLoad(with args: Object) -> Bool {
                obj = args
                return true
            }
        }
        class FR3: TestFlowRepresentable<Object, Object>, FlowRepresentable {
            static var shouldMoveOn = false
            var obj: Object!
            func shouldLoad(with args: Object) -> Bool {
                defer {
                    FR3.shouldMoveOn.toggle()
                }

                obj = args

                if FR3.shouldMoveOn {
                    return false
                }
                proceedBackwardInWorkflow()
                return true
            }
        }
        let wf = Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)
        let responder = MockOrchestrationResponder()
        wf.applyOrchestrationResponder(responder)
        let expectation = self.expectation(description: "OnFinish called")

        let launchedRepresentable = wf.launch(with: val) { args in
            XCTAssert(args as? Object === val)
            expectation.fulfill()
        }

        XCTAssert((launchedRepresentable?.value?.underlyingInstance as? FR1)?.obj === val)
        (launchedRepresentable?.value?.underlyingInstance as? FR1)?.proceedInWorkflow(val)
        XCTAssert((responder.lastTo?.instance.value?.underlyingInstance as? FR2)?.obj === val)
        (responder.lastTo?.instance.value?.underlyingInstance as? FR2)?.proceedInWorkflow(val)
        XCTAssert((responder.lastTo?.instance.value?.underlyingInstance as? FR3)?.obj === val)
        (responder.lastTo?.instance.value?.underlyingInstance as? FR3)?.proceedBackwardInWorkflow()
        XCTAssert((responder.lastTo?.instance.value?.underlyingInstance as? FR2)?.obj === val)
        (responder.lastTo?.instance.value?.underlyingInstance as? FR2)?.proceedInWorkflow(val)
        XCTAssert((responder.lastTo?.instance.value?.underlyingInstance as? FR2)?.obj === val)
        (responder.lastTo?.instance.value?.underlyingInstance as? FR3)?.proceedInWorkflow(val)
        XCTAssert((responder.lastTo?.instance.value?.underlyingInstance as? FR2)?.obj === val)
        (responder.lastTo?.instance.value?.underlyingInstance as? FR3)?.proceedInWorkflow(val)

        wait(for: [expectation], timeout: 3)
    }
}

extension OrchestrationResponderTests {
    class TestFlowRepresentable<Input, Output> {
        weak var _workflowPointer: AnyFlowRepresentable?

        required init() { }
        static func instance() -> Self { Self() }

        typealias WorkflowInput = Input
        typealias WorkflowOutput = Output
    }

    class TestPassthroughFlowRepresentable: FlowRepresentable {
        weak var _workflowPointer: AnyFlowRepresentable?

        required init() { }

        static func instance() -> Self { Self() }

        typealias WorkflowInput = Never
        typealias WorkflowOutput = Never
    }
}
