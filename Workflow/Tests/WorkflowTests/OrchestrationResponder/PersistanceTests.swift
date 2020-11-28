//
//  PersistanceTests.swift
//  
//
//  Created by Tyler Thompson on 11/25/20.
//

import Foundation
import XCTest

@testable import Workflow

class PersistanceTests: XCTestCase {
//    func testWorkflowCanDestroyFirstItem_AndStillProceedThroughFlow_AndCallOnFinish() {
//        class FR1: TestPassthroughFlowRepresentable { }
//        class FR2: TestPassthroughFlowRepresentable { }
//        class FR3: TestPassthroughFlowRepresentable { }
//        let wf = Workflow(FR1.self, flowPersistance: .removedAfterProceeding)
//            .thenPresent(FR2.self)
//            .thenPresent(FR3.self)
//        let responder = MockOrchestrationResponder()
//        wf.applyOrchestrationResponder(responder)
//
//        let launchedRepresentable = wf.launch(from: nil, with: nil)
//
//        XCTAssertEqual(responder.proceedCalled, 1)
//        XCTAssert(launchedRepresentable?.value is FR1)
//        XCTAssert(responder.lastTo is FR1)
//        XCTAssert(responder.lastMetadata?.flowRepresentableType == FR1.self)
//
//        weak var fr1 = (responder.lastTo as? FR1)
//        XCTAssertNotNil(fr1)
//        fr1?.proceedInWorkflow()
//
//        XCTAssertNil(fr1)
//        XCTAssertEqual(responder.proceedCalled, 2)
//        XCTAssert(responder.lastTo is FR2)
//        XCTAssert((responder.lastFrom as? FR1) === fr1)
//        XCTAssert(responder.lastMetadata?.flowRepresentableType == FR2.self)
//    }
//
//    func testWorkflowCanDestroyMiddleItem_AndStillProceedThroughFlow_AndCallOnFinish() {
//        class FR1: TestPassthroughFlowRepresentable { }
//        class FR2: TestPassthroughFlowRepresentable { }
//        class FR3: TestPassthroughFlowRepresentable { }
//        let wf = Workflow(FR1.self)
//            .thenPresent(FR2.self, flowPersistance: .removedAfterProceeding)
//            .thenPresent(FR3.self)
//        let responder = MockOrchestrationResponder()
//        wf.applyOrchestrationResponder(responder)
//
//        let launchedRepresentable = wf.launch(from: nil, with: nil)
//
//        XCTAssertEqual(responder.proceedCalled, 1)
//        XCTAssert(launchedRepresentable?.value is FR1)
//        XCTAssert(responder.lastTo is FR1)
//        XCTAssert(responder.lastMetadata?.flowRepresentableType == FR1.self)
//
//        let fr1 = (responder.lastTo as? FR1)
//        fr1?.proceedInWorkflow()
//
//        XCTAssertEqual(responder.proceedCalled, 2)
//        XCTAssert(responder.lastTo is FR2)
//        XCTAssertNotNil(responder.lastFrom)
//        XCTAssert(responder.lastFrom is FR1)
//        XCTAssert((responder.lastFrom as? FR1) === fr1)
//        XCTAssert(responder.lastMetadata?.flowRepresentableType == FR2.self)
//
//        weak var fr2 = (responder.lastTo as? FR2)
//        XCTAssertNotNil(fr2)
//        fr2?.proceedInWorkflow()
//
//        XCTAssertNil(fr2)
//        let fr3 = (responder.lastTo as? FR3)
//        fr3?.proceedInWorkflow()
//
//        XCTAssertEqual(responder.proceedCalled, 3)
//        XCTAssert(responder.lastTo is FR3)
//        XCTAssert(responder.lastMetadata?.flowRepresentableType == FR3.self)
//    }
//
//    func testWorkflowCanDestroyLastItem_AndStillProceedThroughFlow_AndCallOnFinish() {
//        class FR1: TestPassthroughFlowRepresentable { }
//        class FR2: TestPassthroughFlowRepresentable { }
//        class FR3: TestPassthroughFlowRepresentable { }
//        let wf = Workflow(FR1.self)
//            .thenPresent(FR2.self)
//            .thenPresent(FR3.self, flowPersistance: .removedAfterProceeding)
//        let responder = MockOrchestrationResponder()
//        wf.applyOrchestrationResponder(responder)
//
//        let expectation = self.expectation(description: "onFinish called")
//
//        let launchedRepresentable = wf.launch(from: nil, with: nil) { _ in expectation.fulfill() }
//
//        XCTAssertEqual(responder.proceedCalled, 1)
//        XCTAssert(launchedRepresentable?.value is FR1)
//        XCTAssert(responder.lastTo is FR1)
//        XCTAssert(responder.lastMetadata?.flowRepresentableType == FR1.self)
//
//        let fr1 = (responder.lastTo as? FR1)
//        fr1?.proceedInWorkflow()
//
//        XCTAssertEqual(responder.proceedCalled, 2)
//        XCTAssert(responder.lastTo is FR2)
//        XCTAssertNotNil(responder.lastFrom)
//        XCTAssert(responder.lastFrom is FR1)
//        XCTAssert((responder.lastFrom as? FR1) === fr1)
//        XCTAssert(responder.lastMetadata?.flowRepresentableType == FR2.self)
//
//        let fr2 = (responder.lastTo as? FR2)
//        fr2?.proceedInWorkflow()
//
//        XCTAssertEqual(responder.proceedCalled, 3)
//        XCTAssert(responder.lastTo is FR3)
//        XCTAssertNotNil(responder.lastFrom)
//        XCTAssert(responder.lastFrom is FR2)
//        XCTAssert((responder.lastFrom as? FR2) === fr2)
//        XCTAssert(responder.lastMetadata?.flowRepresentableType == FR3.self)
//
//        weak var fr3 = (responder.lastTo as? FR3)
//        XCTAssertNotNil(fr3)
//        fr3?.proceedInWorkflow()
//
//        XCTAssertNil(fr3)
//
//        wait(for: [expectation], timeout: 3)
//    }
//
//    func testWorkflowCanDestroyMultipleItems_AndStillProceedThroughFlow_PassingThroughCorrectArgsToNextWorkflowItem() {
//        class FR1: TestFlowRepresentable<Never, String>, FlowRepresentable {
//            static let id = UUID().uuidString
//            func shouldLoad() -> Bool {
//                proceedInWorkflow(FR1.id)
//                return false
//            }
//        }
//        class FR2: TestFlowRepresentable<String, String>, FlowRepresentable {
//            static let expectation = XCTestExpectation(description: "shouldLoad called")
//            func shouldLoad(with id: String) -> Bool {
//                FR2.expectation.fulfill()
//                XCTAssertEqual(id, FR1.id)
//                proceedInWorkflow(id)
//                return false
//            }
//        }
//        class FR3: TestFlowRepresentable<String, Never>, FlowRepresentable {
//            static let expectation = XCTestExpectation(description: "shouldLoad called")
//            func shouldLoad(with id: String) -> Bool {
//                FR3.expectation.fulfill()
//                XCTAssertEqual(id, FR1.id)
//                return true
//            }
//        }
//        let wf = Workflow(FR1.self)
//            .thenPresent(FR2.self)
//            .thenPresent(FR3.self)
//        let responder = MockOrchestrationResponder()
//        wf.applyOrchestrationResponder(responder)
//
//        let launchedRepresentable = wf.launch(from: nil, with: nil)
//
//        XCTAssertEqual(responder.proceedCalled, 1)
//        XCTAssert(launchedRepresentable?.value is FR3)
//        XCTAssert(responder.lastTo is FR3)
//        XCTAssertNil(responder.lastFrom)
//        XCTAssert(responder.lastMetadata?.flowRepresentableType == FR3.self)
//
//        (responder.lastTo as? FR3)?.proceedInWorkflow()
//
//        wait(for: [FR2.expectation, FR3.expectation], timeout: 3)
//    }
//
//    func testWorkflowCanDestroyAllItems_AndStillProceedThroughFlow_PassingThroughInitialArgsToNextWorkflowItem() {
//        class FR1: TestFlowRepresentable<String, String>, FlowRepresentable {
//            static let id = UUID().uuidString
//            func shouldLoad(with id: String) -> Bool {
//                return false
//            }
//        }
//        class FR2: TestFlowRepresentable<String, String>, FlowRepresentable {
//            static let expectation = XCTestExpectation(description: "shouldLoad called")
//            func shouldLoad(with id: String) -> Bool {
//                FR2.expectation.fulfill()
//                XCTAssertEqual(id, FR1.id)
//                return false
//            }
//        }
//        class FR3: TestFlowRepresentable<String, String>, FlowRepresentable {
//            static let expectation = XCTestExpectation(description: "shouldLoad called")
//            func shouldLoad(with id: String) -> Bool {
//                FR3.expectation.fulfill()
//                XCTAssertEqual(id, FR1.id)
//                return false
//            }
//        }
//        let expectation = self.expectation(description: "onFinish called")
//        let wf = Workflow(FR1.self)
//            .thenPresent(FR2.self)
//            .thenPresent(FR3.self)
//        let responder = MockOrchestrationResponder()
//        wf.applyOrchestrationResponder(responder)
//
//        let launchedRepresentable = wf.launch(from: nil, with: FR1.id) { id in
//            expectation.fulfill()
//            XCTAssertEqual(id as? String, FR1.id)
//        }
//
//        XCTAssertEqual(responder.proceedCalled, 0)
//        XCTAssertNil(launchedRepresentable)
//        XCTAssertNil(responder.lastTo)
//        XCTAssertNil(responder.lastFrom)
//
//        wait(for: [FR2.expectation, FR3.expectation, expectation], timeout: 3)
//    }
}

extension PersistanceTests {
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
