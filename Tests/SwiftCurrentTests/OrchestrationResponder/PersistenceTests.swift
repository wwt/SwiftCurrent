//
//  PersistenceTests.swift
//  
//
//  Created by Tyler Thompson on 11/25/20.
//

import Foundation
import XCTest

@testable import SwiftCurrent

class PersistenceTests: XCTestCase {
    func testWorkflowCanDestroyFirstItem_AndStillProceedThroughFlow() {
        class FR1: TestPassthroughFlowRepresentable { }
        class FR2: TestPassthroughFlowRepresentable { }
        class FR3: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self, flowPersistence: .removedAfterProceeding)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self)
        let responder = MockOrchestrationResponder()

        let launchedRepresentable = wf.launch(withOrchestrationResponder: responder)

        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value.instance?.underlyingInstance is FR1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR1)

        weak var fr1 = (responder.lastTo?.value.instance?.underlyingInstance as? FR1)
        XCTAssertNotNil(fr1)
        fr1?.proceedInWorkflow()

        XCTAssertNil(fr1)
        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR2)
        XCTAssert((responder.lastFrom?.value.instance?.underlyingInstance as? FR1) === fr1)
    }

    func testWorkflowCanDestroyMiddleItem_AndStillProceedThroughFlow_AndCallOnFinish() {
        class FR1: TestPassthroughFlowRepresentable { }
        class FR2: TestPassthroughFlowRepresentable { }
        class FR3: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self, flowPersistence: .removedAfterProceeding)
            .thenProceed(with: FR3.self)
        let responder = MockOrchestrationResponder()
        responder.complete_EnableDefaultImplementation = true

        let expectOnFinish = expectation(description: "Expected onFinish to complete")
        let launchedRepresentable = wf.launch(withOrchestrationResponder: responder) { _ in expectOnFinish.fulfill() }

        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value.instance?.underlyingInstance is FR1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR1)

        let fr1 = (responder.lastTo?.value.instance?.underlyingInstance as? FR1)
        fr1?.proceedInWorkflow()

        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR2)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.value.instance?.underlyingInstance is FR1)
        XCTAssert((responder.lastFrom?.value.instance?.underlyingInstance as? FR1) === fr1)

        weak var fr2 = (responder.lastTo?.value.instance?.underlyingInstance as? FR2)
        XCTAssertNotNil(fr2)
        fr2?.proceedInWorkflow()
        XCTAssertNil(fr2)
        XCTAssertEqual(responder.proceedCalled, 2)
        XCTAssertEqual(responder.completeCalled, 0)

        let fr3 = (responder.lastTo?.value.instance?.underlyingInstance as? FR3)
        XCTAssertNotNil(fr3)
        fr3?.proceedInWorkflow()

        XCTAssertEqual(responder.proceedCalled, 2)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR3)
        XCTAssertEqual(responder.completeCalled, 1)

        wait(for: [expectOnFinish], timeout: 3)
    }

    func testWorkflowCanDestroyLastItem_AndStillProceedThroughFlow_AndCallOnFinish() {
        class FR1: TestPassthroughFlowRepresentable { }
        class FR2: TestPassthroughFlowRepresentable { }
        class FR3: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self, flowPersistence: .removedAfterProceeding)
        let responder = MockOrchestrationResponder()
        responder.complete_EnableDefaultImplementation = true

        let expectation = self.expectation(description: "onFinish called")
        let launchedRepresentable = wf.launch(withOrchestrationResponder: responder) { _ in
            XCTAssertNotNil((responder.lastTo?.value.instance?.underlyingInstance as? FR3))
            expectation.fulfill()
        }

        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value.instance?.underlyingInstance is FR1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR1)

        let fr1 = (responder.lastTo?.value.instance?.underlyingInstance as? FR1)
        fr1?.proceedInWorkflow()

        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR2)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.value.instance?.underlyingInstance is FR1)
        XCTAssert((responder.lastFrom?.value.instance?.underlyingInstance as? FR1) === fr1)

        let fr2 = (responder.lastTo?.value.instance?.underlyingInstance as? FR2)
        fr2?.proceedInWorkflow()

        XCTAssertEqual(responder.proceedCalled, 2)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR3)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.value.instance?.underlyingInstance is FR2)
        XCTAssert((responder.lastFrom?.value.instance?.underlyingInstance as? FR2) === fr2)
        XCTAssertEqual(responder.completeCalled, 0)

        weak var fr3 = (responder.lastTo?.value.instance?.underlyingInstance as? FR3)
        XCTAssertNotNil(fr3)
        fr3?.proceedInWorkflow()

        XCTAssertNil(fr3)
        XCTAssertEqual(responder.completeCalled, 1)

        wait(for: [expectation], timeout: 3)
    }

    func testWorkflowCanDestroyMultipleItems_AndStillProceedThroughFlow_AndCallOnFinish() {
        class FR1: TestPassthroughFlowRepresentable { }
        class FR2: TestPassthroughFlowRepresentable { }
        class FR3: TestPassthroughFlowRepresentable { }
        class FR4: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self, flowPersistence: .removedAfterProceeding)
            .thenProceed(with: FR3.self, flowPersistence: .removedAfterProceeding)
            .thenProceed(with: FR4.self)
        let responder = MockOrchestrationResponder()
        responder.complete_EnableDefaultImplementation = true

        let expectOnFinish = self.expectation(description: "onFinish called")
        let launchedRepresentable = wf.launch(withOrchestrationResponder: responder) { _ in expectOnFinish.fulfill() }

        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value.instance?.underlyingInstance is FR1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR1)

        let fr1 = (responder.lastTo?.value.instance?.underlyingInstance as? FR1)
        fr1?.proceedInWorkflow()

        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR2)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.value.instance?.underlyingInstance is FR1)
        XCTAssert((responder.lastFrom?.value.instance?.underlyingInstance as? FR1) === fr1)

        weak var fr2 = (responder.lastTo?.value.instance?.underlyingInstance as? FR2)
        XCTAssertNotNil(fr2)
        fr2?.proceedInWorkflow()

        XCTAssertNil(fr2)
        XCTAssertEqual(responder.proceedCalled, 2)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR3)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssertNil(responder.lastFrom?.value.instance)

        weak var fr3 = (responder.lastTo?.value.instance?.underlyingInstance as? FR3)
        XCTAssertNotNil(fr3)
        fr3?.proceedInWorkflow()

        XCTAssertNil(fr3)
        XCTAssertEqual(responder.proceedCalled, 3)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR4)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssertNil(responder.lastFrom?.value.instance)
        XCTAssertEqual(responder.completeCalled, 0)

        let fr4 = (responder.lastTo?.value.instance?.underlyingInstance as? FR4)
        fr4?.proceedInWorkflow()

        XCTAssertEqual(responder.proceedCalled, 3)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssertNil(responder.lastFrom?.value.instance)
        XCTAssertEqual(responder.completeCalled, 1)

        wait(for: [expectOnFinish], timeout: 3)
    }

    func testWorkflowCanDestroyAllItems_AndStillProceedThroughFlow_AndCallOnFinish() {
        class FR1: TestPassthroughFlowRepresentable { }
        class FR2: TestPassthroughFlowRepresentable { }
        class FR3: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self, flowPersistence: .removedAfterProceeding)
            .thenProceed(with: FR2.self, flowPersistence: .removedAfterProceeding)
            .thenProceed(with: FR3.self, flowPersistence: .removedAfterProceeding)
        let responder = MockOrchestrationResponder()
        responder.complete_EnableDefaultImplementation = true

        let expectOnFinish = self.expectation(description: "onFinish called")
        let launchedRepresentable = wf.launch(withOrchestrationResponder: responder) { _ in
            XCTAssertNotNil((responder.lastTo?.value.instance?.underlyingInstance as? FR3))
            expectOnFinish.fulfill()
        }

        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value.instance?.underlyingInstance is FR1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR1)

        weak var fr1 = (responder.lastTo?.value.instance?.underlyingInstance as? FR1)
        XCTAssertNotNil(fr1)
        fr1?.proceedInWorkflow()

        XCTAssertNil(fr1)
        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR2)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssertNil(responder.lastFrom?.value.instance)

        weak var fr2 = (responder.lastTo?.value.instance?.underlyingInstance as? FR2)
        XCTAssertNotNil(fr2)
        fr2?.proceedInWorkflow()

        XCTAssertNil(fr2)
        XCTAssertEqual(responder.proceedCalled, 2)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR3)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssertNil(responder.lastFrom?.value.instance)
        XCTAssertEqual(responder.completeCalled, 0)

        weak var fr3 = (responder.lastTo?.value.instance?.underlyingInstance as? FR3)
        XCTAssertNotNil(fr3)
        fr3?.proceedInWorkflow()

        XCTAssertNil(fr3)
        XCTAssertEqual(responder.proceedCalled, 2)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssertNil(responder.lastFrom?.value.instance)
        XCTAssertEqual(responder.completeCalled, 1)

        wait(for: [expectOnFinish], timeout: 3)
    }
}

extension PersistenceTests {
    class TestFlowRepresentable<Input, Output> {
        weak var _workflowPointer: AnyFlowRepresentable?

        required init() { }

        typealias WorkflowInput = Input
        typealias WorkflowOutput = Output
    }

    class TestPassthroughFlowRepresentable: FlowRepresentable {
        weak var _workflowPointer: AnyFlowRepresentable?

        required init() { }
    }
}
