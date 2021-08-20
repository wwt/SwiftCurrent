//
//  OrchestrationResponderTests.swift
//  
//
//  Created by Tyler Thompson on 11/24/20.
//

import Foundation
import XCTest

import SwiftCurrent
import SwiftCurrent_Testing

class OrchestrationResponderTests: XCTestCase {
    func testWorkflowCanProceedForwardThroughFlow() {
        class FR1: TestPassthroughFlowRepresentable { }
        class FR2: TestPassthroughFlowRepresentable { }
        class FR3: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self)
        let responder = MockOrchestrationResponder()

        let launchedRepresentable = wf.launch(withOrchestrationResponder: responder)

        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value.instance?.underlyingInstance is FR1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR1)
        XCTAssertNil(responder.lastFrom)

        (launchedRepresentable?.value.instance?.underlyingInstance as? FR1)?.proceedInWorkflow()

        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR2)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.value.instance?.underlyingInstance is FR1)
        XCTAssert((responder.lastFrom?.value.instance?.underlyingInstance as? FR1) === (launchedRepresentable?.value.instance?.underlyingInstance as? FR1))

        let fr2 = (responder.lastTo?.value.instance?.underlyingInstance as? FR2)
        fr2?.proceedInWorkflow()

        XCTAssertEqual(responder.proceedCalled, 2)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR3)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.value.instance?.underlyingInstance is FR2)
        XCTAssert((responder.lastFrom?.value.instance?.underlyingInstance as? FR2) === fr2)
    }

    func testWorkflowCallsOnFinishWhenItIsDone() {
        class FR1: TestPassthroughFlowRepresentable { }
        class FR2: TestPassthroughFlowRepresentable { }
        class FR3: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self)
        let responder = MockOrchestrationResponder()
        responder.complete_EnableDefaultImplementation = true
        let expectation = self.expectation(description: "OnFinish called")

        let launchedRepresentable = wf.launch(withOrchestrationResponder: responder) { _ in expectation.fulfill() }

        (launchedRepresentable?.value.instance?.underlyingInstance as? FR1)?.proceedInWorkflow()
        (responder.lastTo?.value.instance?.underlyingInstance as? FR2)?.proceedInWorkflow()
        (responder.lastTo?.value.instance?.underlyingInstance as? FR3)?.proceedInWorkflow()

        wait(for: [expectation], timeout: 3)

        XCTAssertEqual(responder.completeCalled, 1)
        XCTAssertNotNil(responder.lastPassedArgs)
        XCTAssertNotNil(responder.lastCompleteOnFinish)
    }

    func testWorkflowCallsOnFinishWhenItIsDone_andPassesForwardLastArguments() {
        class Object { }
        let val = Object()
        class FR1: TestPassthroughFlowRepresentable { }
        class FR2: TestPassthroughFlowRepresentable { }
        final class FR3: TestFlowRepresentable<Never, Object>, FlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self)
        let responder = MockOrchestrationResponder()
        responder.complete_EnableDefaultImplementation = true
        let expectation = self.expectation(description: "OnFinish called")

        let launchedRepresentable = wf.launch(withOrchestrationResponder: responder) { args in
            XCTAssert(args.extractArgs(defaultValue: nil) as? Object === val)
            expectation.fulfill()
        }

        (launchedRepresentable?.value.instance?.underlyingInstance as? FR1)?.proceedInWorkflow()
        (responder.lastTo?.value.instance?.underlyingInstance as? FR2)?.proceedInWorkflow()
        (responder.lastTo?.value.instance?.underlyingInstance as? FR3)?.proceedInWorkflow(val)

        wait(for: [expectation], timeout: 3)

        XCTAssertEqual(responder.completeCalled, 1)
        XCTAssertNotNil(responder.lastPassedArgs)
        XCTAssertNotNil(responder.lastCompleteOnFinish)
    }

    func testWorkflowCanProceedForwardAndBackwardThroughFlow() {
        class FR1: TestPassthroughFlowRepresentable { }
        class FR2: TestPassthroughFlowRepresentable { }
        class FR3: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self)
        let responder = MockOrchestrationResponder()

        let launchedRepresentable = wf.launch(withOrchestrationResponder: responder)

        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value.instance?.underlyingInstance is FR1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR1)
        XCTAssertNil(responder.lastFrom)

        (launchedRepresentable?.value.instance?.underlyingInstance as? FR1)?.proceedInWorkflow()

        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR2)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.value.instance?.underlyingInstance is FR1)
        XCTAssert((responder.lastFrom?.value.instance?.underlyingInstance as? FR1) === (launchedRepresentable?.value.instance?.underlyingInstance as? FR1))

        let fr2 = (responder.lastTo?.value.instance?.underlyingInstance as? FR2)
        try? fr2?.backUpInWorkflow()
        XCTAssertEqual(responder.backUpCalled, 1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR1)
        XCTAssertNotNil(responder.lastTo)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR1)
        XCTAssert((responder.lastTo?.value.instance?.underlyingInstance as? FR1) === (launchedRepresentable?.value.instance?.underlyingInstance as? FR1))

        fr2?.proceedInWorkflow()

        XCTAssertEqual(responder.proceedCalled, 2)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR3)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.value.instance?.underlyingInstance is FR2)
        XCTAssert((responder.lastFrom?.value.instance?.underlyingInstance as? FR2) === fr2)
    }

    func testWorkflowCallsOnFinishWhenItIsDone_EvenWhenMovingBackwardsForABit() {
        class FR1: TestPassthroughFlowRepresentable { }
        class FR2: TestPassthroughFlowRepresentable { }
        class FR3: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self)
        let responder = MockOrchestrationResponder()
        responder.complete_EnableDefaultImplementation = true
        let expectation = self.expectation(description: "OnFinish called")

        let launchedRepresentable = wf.launch(withOrchestrationResponder: responder) { _ in expectation.fulfill() }

        (launchedRepresentable?.value.instance?.underlyingInstance as? FR1)?.proceedInWorkflow()
        (responder.lastTo?.value.instance?.underlyingInstance as? FR2)?.proceedInWorkflow()
        try? (responder.lastTo?.value.instance?.underlyingInstance as? FR2)?.backUpInWorkflow()
        (responder.lastTo?.value.instance?.underlyingInstance as? FR1)?.proceedInWorkflow()
        (responder.lastTo?.value.instance?.underlyingInstance as? FR2)?.proceedInWorkflow()
        (responder.lastTo?.value.instance?.underlyingInstance as? FR3)?.proceedInWorkflow()

        wait(for: [expectation], timeout: 3)

        XCTAssertEqual(responder.completeCalled, 1)
        XCTAssertNotNil(responder.lastPassedArgs)
        XCTAssertNotNil(responder.lastCompleteOnFinish)
    }

    func testWorkflowCallsOnFinishWhenItIsDone_andPassesForwardInitialArguments_EvenWhenMovingBackwardsForABit() {
        class Object { }
        let val = Object()
        final class FR1: TestFlowRepresentable<Object, Object>, FlowRepresentable {
            var obj: Object

            required init(with object: Object) {
                self.obj = object
            }
        }
        class FR2: TestFlowRepresentable<Object, Object>, FlowRepresentable {
            var obj: Object

            required init(with object: Object) {
                self.obj = object
            }
        }
        class FR3: TestFlowRepresentable<Object, Object>, FlowRepresentable {
            static var shouldMoveOn = false
            var obj: Object

            required init(with object: Object) {
                self.obj = object
            }

            func shouldLoad() -> Bool {
                defer {
                    FR3.shouldMoveOn.toggle()
                }

                if FR3.shouldMoveOn {
                    return false
                }
                try? backUpInWorkflow()
                return true
            }
        }
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self)
        let responder = MockOrchestrationResponder()
        responder.complete_EnableDefaultImplementation = true
        let expectation = self.expectation(description: "OnFinish called")

        let launchedRepresentable = wf.launch(withOrchestrationResponder: responder,
                                              args: val) { args in
            XCTAssert(args.extractArgs(defaultValue: nil) as? Object === val)
            expectation.fulfill()
        }

        XCTAssert((launchedRepresentable?.value.instance?.underlyingInstance as? FR1)?.obj === val)
        (launchedRepresentable?.value.instance?.underlyingInstance as? FR1)?.proceedInWorkflow(val)
        XCTAssert((responder.lastTo?.value.instance?.underlyingInstance as? FR2)?.obj === val)
        (responder.lastTo?.value.instance?.underlyingInstance as? FR2)?.proceedInWorkflow(val)
        XCTAssert((responder.lastTo?.value.instance?.underlyingInstance as? FR3)?.obj === val)
        try? (responder.lastTo?.value.instance?.underlyingInstance as? FR3)?.backUpInWorkflow()
        XCTAssert((responder.lastTo?.value.instance?.underlyingInstance as? FR2)?.obj === val)
        (responder.lastTo?.value.instance?.underlyingInstance as? FR2)?.proceedInWorkflow(val)
        XCTAssert((responder.lastTo?.value.instance?.underlyingInstance as? FR2)?.obj === val)
        (responder.lastTo?.value.instance?.underlyingInstance as? FR3)?.proceedInWorkflow(val)
        XCTAssert((responder.lastTo?.value.instance?.underlyingInstance as? FR2)?.obj === val)
        (responder.lastTo?.value.instance?.underlyingInstance as? FR3)?.proceedInWorkflow(val)

        wait(for: [expectation], timeout: 3)

        XCTAssertEqual(responder.completeCalled, 1)
        XCTAssertNotNil(responder.lastPassedArgs)
        XCTAssertNotNil(responder.lastCompleteOnFinish)
    }
}

extension OrchestrationResponderTests {
    class TestFlowRepresentable<Input, Output> {
        weak var _workflowPointer: AnyFlowRepresentable?

        typealias WorkflowInput = Input
        typealias WorkflowOutput = Output
    }

    class TestPassthroughFlowRepresentable: FlowRepresentable {
        weak var _workflowPointer: AnyFlowRepresentable?
        required init() { }
    }
}
