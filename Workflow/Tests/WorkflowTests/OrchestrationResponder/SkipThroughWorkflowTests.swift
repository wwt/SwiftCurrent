//
//  SkipThroughWorkflowTests.swift
//  
//
//  Created by Tyler Thompson on 11/24/20.
//

import Foundation
import XCTest

import Workflow

class SkipThroughWorkflowTests: XCTestCase {
    func testWorkflowCanSkipFirstItem_AndStillProceedThroughFlow_AndCallOnFinish() {
        class FR1: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            func shouldLoad() -> Bool { false }
        }
        class FR2: TestPassthroughFlowRepresentable { }
        class FR3: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)
        let responder = MockOrchestrationResponder()
        wf.applyOrchestrationResponder(responder)
        
        let expectation = self.expectation(description: "OnFinish called")
        
        let launchedRepresentable = wf.launch(with: nil) { _ in expectation.fulfill() }
        
        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value is FR2)
        XCTAssert(responder.lastTo?.instance.value is FR2)
        XCTAssertNil(responder.lastFrom)
        XCTAssert(responder.lastTo?.metadata.flowRepresentableType == FR2.self)
        
        let fr2 = (responder.lastTo?.instance.value as? FR2)
        fr2?.proceedInWorkflow()
        
        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert(responder.lastTo?.instance.value is FR3)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.instance.value is FR2)
        XCTAssert((responder.lastFrom?.instance.value as? FR2) === fr2)
        XCTAssert(responder.lastTo?.metadata.flowRepresentableType == FR3.self)
        
        (responder.lastTo?.instance.value as? FR3)?.proceedInWorkflow()
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testWorkflowCanSkipMiddleItem_AndStillProceedThroughFlow_AndCallOnFinish() {
        class FR1: TestPassthroughFlowRepresentable { }
        class FR2: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            func shouldLoad() -> Bool { false }
        }
        class FR3: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)
        let responder = MockOrchestrationResponder()
        wf.applyOrchestrationResponder(responder)
        
        let expectation = self.expectation(description: "OnFinish called")
        
        let launchedRepresentable = wf.launch(with: nil) { _ in expectation.fulfill() }
        
        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value is FR1)
        XCTAssert(responder.lastTo?.instance.value is FR1)
        XCTAssertNil(responder.lastFrom)
        XCTAssert(responder.lastTo?.metadata.flowRepresentableType == FR1.self)
        
        let fr1 = (responder.lastTo?.instance.value as? FR1)
        fr1?.proceedInWorkflow()
        
        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert(responder.lastTo?.instance.value is FR3)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.instance.value is FR1)
        XCTAssert((responder.lastFrom?.instance.value as? FR1) === fr1)
        XCTAssert(responder.lastTo?.metadata.flowRepresentableType == FR3.self)
        
        (responder.lastTo?.instance.value as? FR3)?.proceedInWorkflow()
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testWorkflowCanSkipLastItem_AndStillProceedThroughFlow_AndCallOnFinish() {
        class FR1: TestPassthroughFlowRepresentable { }
        class FR2: TestPassthroughFlowRepresentable { }
        class FR3: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            func shouldLoad() -> Bool { false }
        }
        let wf = Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)
        let responder = MockOrchestrationResponder()
        wf.applyOrchestrationResponder(responder)
        
        let expectation = self.expectation(description: "OnFinish called")
        
        let launchedRepresentable = wf.launch(with: nil) { _ in expectation.fulfill() }
        
        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value is FR1)
        XCTAssert(responder.lastTo?.instance.value is FR1)
        XCTAssertNil(responder.lastFrom)
        XCTAssert(responder.lastTo?.metadata.flowRepresentableType == FR1.self)
        
        let fr1 = (responder.lastTo?.instance.value as? FR1)
        fr1?.proceedInWorkflow()
        
        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(responder.lastTo?.instance.value is FR2)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.instance.value is FR1)
        XCTAssert((responder.lastFrom?.instance.value as? FR1) === fr1)
        XCTAssert(responder.lastTo?.metadata.flowRepresentableType == FR2.self)
        
        (responder.lastTo?.instance.value as? FR2)?.proceedInWorkflow()
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testWorkflowCanSkipFirstItem_AndStillProceedThroughFlow_PassingThroughCorrectArgsToNextWorkflowItem() {
        class FR1: TestFlowRepresentable<Never, String>, FlowRepresentable {
            static let id = UUID().uuidString
            func shouldLoad() -> Bool {
                proceedInWorkflow(FR1.id)
                return false
            }
        }
        class FR2: TestFlowRepresentable<String, Never>, FlowRepresentable {
            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad(with id: String) -> Bool {
                FR2.expectation.fulfill()
                XCTAssertEqual(id, FR1.id)
                return true
            }
        }
        class FR3: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)
        let responder = MockOrchestrationResponder()
        wf.applyOrchestrationResponder(responder)
        
        let launchedRepresentable = wf.launch(with: nil)
        
        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value is FR2)
        XCTAssert(responder.lastTo?.instance.value is FR2)
        XCTAssertNil(responder.lastFrom)
        XCTAssert(responder.lastTo?.metadata.flowRepresentableType == FR2.self)
        
        let fr2 = (responder.lastTo?.instance.value as? FR2)
        fr2?.proceedInWorkflow()
        
        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert(responder.lastTo?.instance.value is FR3)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.instance.value is FR2)
        XCTAssert((responder.lastFrom?.instance.value as? FR2) === fr2)
        XCTAssert(responder.lastTo?.metadata.flowRepresentableType == FR3.self)
        
        (responder.lastTo?.instance.value as? FR3)?.proceedInWorkflow()
        
        wait(for: [FR2.expectation], timeout: 3)
    }
    
    func testWorkflowCanSkipMultipleItems_AndStillProceedThroughFlow_PassingThroughCorrectArgsToNextWorkflowItem() {
        class FR1: TestFlowRepresentable<Never, String>, FlowRepresentable {
            static let id = UUID().uuidString
            func shouldLoad() -> Bool {
                proceedInWorkflow(FR1.id)
                return false
            }
        }
        class FR2: TestFlowRepresentable<String, String>, FlowRepresentable {
            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad(with id: String) -> Bool {
                FR2.expectation.fulfill()
                XCTAssertEqual(id, FR1.id)
                proceedInWorkflow(id)
                return false
            }
        }
        class FR3: TestFlowRepresentable<String, Never>, FlowRepresentable {
            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad(with id: String) -> Bool {
                FR3.expectation.fulfill()
                XCTAssertEqual(id, FR1.id)
                return true
            }
        }
        let wf = Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)
        let responder = MockOrchestrationResponder()
        wf.applyOrchestrationResponder(responder)
        
        let launchedRepresentable = wf.launch(with: nil)
        
        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value is FR3)
        XCTAssert(responder.lastTo?.instance.value is FR3)
        XCTAssertNil(responder.lastFrom)
        XCTAssert(responder.lastTo?.metadata.flowRepresentableType == FR3.self)
        
        (responder.lastTo?.instance.value as? FR3)?.proceedInWorkflow()
        
        wait(for: [FR2.expectation, FR3.expectation], timeout: 3)
    }
    
    func testWorkflowCanSkipFirstItem_AndStillProceedThroughFlow_PassingThroughInitialArgsToNextWorkflowItem() {
        class FR1: TestFlowRepresentable<String, String>, FlowRepresentable {
            static let id = UUID().uuidString
            func shouldLoad(with id: String) -> Bool { false }
        }
        class FR2: TestFlowRepresentable<String, Never>, FlowRepresentable {
            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad(with id: String) -> Bool {
                FR2.expectation.fulfill()
                XCTAssertEqual(id, FR1.id)
                return true
            }
        }
        class FR3: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)
        let responder = MockOrchestrationResponder()
        wf.applyOrchestrationResponder(responder)
        
        let launchedRepresentable = wf.launch(with: FR1.id)
        
        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value is FR2)
        XCTAssert(responder.lastTo?.instance.value is FR2)
        XCTAssertNil(responder.lastFrom)
        XCTAssert(responder.lastTo?.metadata.flowRepresentableType == FR2.self)
        
        let fr2 = (responder.lastTo?.instance.value as? FR2)
        fr2?.proceedInWorkflow()
        
        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert(responder.lastTo?.instance.value is FR3)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.instance.value is FR2)
        XCTAssert((responder.lastFrom?.instance.value as? FR2) === fr2)
        XCTAssert(responder.lastTo?.metadata.flowRepresentableType == FR3.self)
        
        (responder.lastTo?.instance.value as? FR3)?.proceedInWorkflow()
        
        wait(for: [FR2.expectation], timeout: 3)
    }
    
    func testWorkflowCanSkipMultipleItems_AndStillProceedThroughFlow_PassingThroughInitialArgsToNextWorkflowItem() {
        class FR1: TestFlowRepresentable<String, String>, FlowRepresentable {
            static let id = UUID().uuidString
            func shouldLoad(with id: String) -> Bool {
                return false
            }
        }
        class FR2: TestFlowRepresentable<String, String>, FlowRepresentable {
            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad(with id: String) -> Bool {
                FR2.expectation.fulfill()
                XCTAssertEqual(id, FR1.id)
                return false
            }
        }
        class FR3: TestFlowRepresentable<String, Never>, FlowRepresentable {
            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad(with id: String) -> Bool {
                FR3.expectation.fulfill()
                XCTAssertEqual(id, FR1.id)
                return true
            }
        }
        let wf = Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)
        let responder = MockOrchestrationResponder()
        wf.applyOrchestrationResponder(responder)
        
        let launchedRepresentable = wf.launch(with: FR1.id)
        
        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value is FR3)
        XCTAssert(responder.lastTo?.instance.value is FR3)
        XCTAssertNil(responder.lastFrom)
        XCTAssert(responder.lastTo?.metadata.flowRepresentableType == FR3.self)
        
        (responder.lastTo?.instance.value as? FR3)?.proceedInWorkflow()
        
        wait(for: [FR2.expectation, FR3.expectation], timeout: 3)
    }
    
    func testWorkflowCanSkipAllItems_AndStillProceedThroughFlow_PassingThroughInitialArgsToNextWorkflowItem() {
        class FR1: TestFlowRepresentable<String, String>, FlowRepresentable {
            static let id = UUID().uuidString
            func shouldLoad(with id: String) -> Bool {
                return false
            }
        }
        class FR2: TestFlowRepresentable<String, String>, FlowRepresentable {
            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad(with id: String) -> Bool {
                FR2.expectation.fulfill()
                XCTAssertEqual(id, FR1.id)
                return false
            }
        }
        class FR3: TestFlowRepresentable<String, String>, FlowRepresentable {
            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad(with id: String) -> Bool {
                FR3.expectation.fulfill()
                XCTAssertEqual(id, FR1.id)
                return false
            }
        }
        let expectation = self.expectation(description: "onFinish called")
        let wf = Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)
        let responder = MockOrchestrationResponder()
        wf.applyOrchestrationResponder(responder)
        
        let launchedRepresentable = wf.launch(with: FR1.id) { id in
            expectation.fulfill()
            XCTAssertEqual(id as? String, FR1.id)
        }
        
        XCTAssertEqual(responder.proceedCalled, 0)
        XCTAssertNil(launchedRepresentable)
        XCTAssertNil(responder.lastTo)
        XCTAssertNil(responder.lastFrom)
        
        wait(for: [FR2.expectation, FR3.expectation, expectation], timeout: 3)
    }
    
    func testWorkflowCanSkipMiddleItem_AndStillProceedThroughFlow_PassingThroughCorrectArgsToNextWorkflowItem() {
        class FR1: TestFlowRepresentable<Never, String>, FlowRepresentable {
            static let id = UUID().uuidString
        }
        class FR2: TestFlowRepresentable<String, String>, FlowRepresentable {
            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad(with id: String) -> Bool {
                FR2.expectation.fulfill()
                XCTAssertEqual(id, FR1.id)
                proceedInWorkflow(id)
                return false
            }
        }
        class FR3: TestFlowRepresentable<String, Never>, FlowRepresentable {
            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad(with id: String) -> Bool {
                FR3.expectation.fulfill()
                XCTAssertEqual(id, FR1.id)
                return true
            }
        }
        let wf = Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)
        let responder = MockOrchestrationResponder()
        wf.applyOrchestrationResponder(responder)
        
        let launchedRepresentable = wf.launch(with: nil)
        
        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value is FR1)
        XCTAssert(responder.lastTo?.instance.value is FR1)
        XCTAssertNil(responder.lastFrom)
        XCTAssert(responder.lastTo?.metadata.flowRepresentableType == FR1.self)
        
        (responder.lastTo?.instance.value as? FR1)?.proceedInWorkflow(FR1.id)
        
        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert(responder.lastTo?.instance.value is FR3)
        XCTAssert(responder.lastFrom?.instance.value is FR1)
        XCTAssert(responder.lastTo?.metadata.flowRepresentableType == FR3.self)
        
        wait(for: [FR2.expectation, FR3.expectation], timeout: 3)
    }
    
    func testWorkflowCanSkipAllExceptTheFirstItem_AndStillProceedThroughFlow_PassingThroughCorrectArgsToNextWorkflowItem() {
        class FR1: TestFlowRepresentable<Never, String>, FlowRepresentable {
            static let id = UUID().uuidString
        }
        class FR2: TestFlowRepresentable<String, String>, FlowRepresentable {
            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad(with id: String) -> Bool {
                FR2.expectation.fulfill()
                XCTAssertEqual(id, FR1.id)
                proceedInWorkflow(id)
                return false
            }
        }
        class FR3: TestFlowRepresentable<String, String>, FlowRepresentable {
            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad(with id: String) -> Bool {
                FR3.expectation.fulfill()
                XCTAssertEqual(id, FR1.id)
                proceedInWorkflow(id)
                return false
            }
        }
        let expectation = self.expectation(description: "onFinish called")
        let wf = Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)
        let responder = MockOrchestrationResponder()
        wf.applyOrchestrationResponder(responder)
        
        let launchedRepresentable = wf.launch(with: nil) { id in
            expectation.fulfill()
            XCTAssertEqual(id as? String, FR1.id)
        }
        
        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value is FR1)
        XCTAssert(responder.lastTo?.instance.value is FR1)
        XCTAssertNil(responder.lastFrom)
        XCTAssert(responder.lastTo?.metadata.flowRepresentableType == FR1.self)
        
        (launchedRepresentable?.value as? FR1)?.proceedInWorkflow(FR1.id)
                
        wait(for: [FR2.expectation, FR3.expectation, expectation], timeout: 3)
    }
}

extension SkipThroughWorkflowTests {
    class TestFlowRepresentable<Input, Output> {
        weak var workflow: AnyWorkflow?
        
        var proceedInWorkflowStorage: ((Any?) -> Void)?

        required init() { }
        static func instance() -> AnyFlowRepresentable { Self() as! AnyFlowRepresentable }

        typealias WorkflowInput = Input
        typealias WorkflowOutput = Output
    }
    
    class TestPassthroughFlowRepresentable: FlowRepresentable {
        weak var workflow: AnyWorkflow?
        
        var proceedInWorkflowStorage: ((Any?) -> Void)?
        
        required init() { }
        
        static func instance() -> AnyFlowRepresentable { Self() }
        
        typealias WorkflowInput = Never
        typealias WorkflowOutput = Never
    }
}
