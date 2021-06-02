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
        final class FR1: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            func shouldLoad() -> Bool { false }
        }
        class FR2: TestPassthroughFlowRepresentable { }
        class FR3: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self)
        let responder = MockOrchestrationResponder()
        responder.complete_EnableDefaultImplementation = true

        let expectation = self.expectation(description: "OnFinish called")

        let launchedRepresentable = wf.launch(withOrchestrationResponder: responder) { _ in expectation.fulfill() }

        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value.instance?.underlyingInstance is FR2)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR2)
        XCTAssertNil(responder.lastFrom)

        let fr2 = (responder.lastTo?.value.instance?.underlyingInstance as? FR2)
        fr2?.proceedInWorkflow()

        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR3)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.value.instance?.underlyingInstance is FR2)
        XCTAssert((responder.lastFrom?.value.instance?.underlyingInstance as? FR2) === fr2)
        XCTAssertEqual(responder.completeCalled, 0)

        (responder.lastTo?.value.instance?.underlyingInstance as? FR3)?.proceedInWorkflow()
        XCTAssertEqual(responder.completeCalled, 1)

        wait(for: [expectation], timeout: 3)
    }

    func testWorkflowCanSkipMiddleItem_AndStillProceedThroughFlow_AndCallOnFinish() {
        class FR1: TestPassthroughFlowRepresentable { }
        final class FR2: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            func shouldLoad() -> Bool { false }
        }
        class FR3: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self)
        let responder = MockOrchestrationResponder()
        responder.complete_EnableDefaultImplementation = true

        let expectation = self.expectation(description: "OnFinish called")

        let launchedRepresentable = wf.launch(withOrchestrationResponder: responder) { _ in expectation.fulfill() }

        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value.instance?.underlyingInstance is FR1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR1)
        XCTAssertNil(responder.lastFrom)

        let fr1 = (responder.lastTo?.value.instance?.underlyingInstance as? FR1)
        fr1?.proceedInWorkflow()

        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR3)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.value.instance?.underlyingInstance is FR1)
        XCTAssert((responder.lastFrom?.value.instance?.underlyingInstance as? FR1) === fr1)
        XCTAssertEqual(responder.completeCalled, 0)

        (responder.lastTo?.value.instance?.underlyingInstance as? FR3)?.proceedInWorkflow()

        XCTAssertEqual(responder.completeCalled, 1)
        wait(for: [expectation], timeout: 3)
    }

    func testWorkflowCanSkipMiddleItem_AndStillProceedFowardAndBackwardThroughFlow_AndCallOnFinish() {
        class FR1: TestPassthroughFlowRepresentable { }
        final class FR2: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            func shouldLoad() -> Bool { false }
        }
        class FR3: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self)
        let responder = MockOrchestrationResponder()
        responder.complete_EnableDefaultImplementation = true

        let expectation = self.expectation(description: "OnFinish called")

        let launchedRepresentable = wf.launch(withOrchestrationResponder: responder) { _ in expectation.fulfill() }

        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value.instance?.underlyingInstance is FR1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR1)
        XCTAssertNil(responder.lastFrom)

        let fr1 = (responder.lastTo?.value.instance?.underlyingInstance as? FR1)
        fr1?.proceedInWorkflow()

        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR3)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.value.instance?.underlyingInstance is FR1)
        XCTAssert((responder.lastFrom?.value.instance?.underlyingInstance as? FR1) === fr1)

        try? (responder.lastTo?.value.instance?.underlyingInstance as? FR3)?.backUpInWorkflow()

        XCTAssertEqual(responder.backUpCalled, 1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR1)
        XCTAssert((responder.lastTo?.value.instance?.underlyingInstance as? FR1) === fr1)
        XCTAssert(responder.lastFrom?.value.instance?.underlyingInstance is FR3)

        let fr1Again = (responder.lastTo?.value.instance?.underlyingInstance as? FR1)
        fr1Again?.proceedInWorkflow()

        XCTAssertEqual(responder.proceedCalled, 2)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR3)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.value.instance?.underlyingInstance is FR1)
        XCTAssert((responder.lastFrom?.value.instance?.underlyingInstance as? FR1) === fr1Again)
        XCTAssertEqual(responder.completeCalled, 0)

        (responder.lastTo?.value.instance?.underlyingInstance as? FR3)?.proceedInWorkflow()

        XCTAssertEqual(responder.completeCalled, 1)
        wait(for: [expectation], timeout: 3)
    }

    func testWorkflowCanSkipLastItem_AndStillProceedThroughFlow_AndCallOnFinish() {
        class FR1: TestPassthroughFlowRepresentable { }
        class FR2: TestPassthroughFlowRepresentable { }
        final class FR3: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            func shouldLoad() -> Bool { false }
        }
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self)
        let responder = MockOrchestrationResponder()
        responder.complete_EnableDefaultImplementation = true

        let expectation = self.expectation(description: "OnFinish called")

        let launchedRepresentable = wf.launch(withOrchestrationResponder: responder) { _ in expectation.fulfill() }

        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value.instance?.underlyingInstance is FR1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR1)
        XCTAssertNil(responder.lastFrom)

        let fr1 = (responder.lastTo?.value.instance?.underlyingInstance as? FR1)
        fr1?.proceedInWorkflow()

        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR2)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.value.instance?.underlyingInstance is FR1)
        XCTAssert((responder.lastFrom?.value.instance?.underlyingInstance as? FR1) === fr1)
        XCTAssertEqual(responder.completeCalled, 0)

        (responder.lastTo?.value.instance?.underlyingInstance as? FR2)?.proceedInWorkflow()

        XCTAssertEqual(responder.completeCalled, 1)
        wait(for: [expectation], timeout: 3)
    }

    func testWorkflowCanSkipFirstItem_AndStillProceedThroughFlow_PassingThroughCorrectArgsToNextWorkflowItem() {
        final class FR1: TestFlowRepresentable<Never, String>, FlowRepresentable {
            static let id = UUID().uuidString
            func shouldLoad() -> Bool {
                proceedInWorkflow(FR1.id)
                return false
            }
        }
        class FR2: TestFlowRepresentable<String, Never>, FlowRepresentable {
            required init(with id: String) { XCTAssertEqual(id, FR1.id) }

            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad() -> Bool {
                FR2.expectation.fulfill()
                return true
            }
        }
        class FR3: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self)
        let responder = MockOrchestrationResponder()

        let launchedRepresentable = wf.launch(withOrchestrationResponder: responder)

        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value.instance?.underlyingInstance is FR2)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR2)
        XCTAssertNil(responder.lastFrom)

        let fr2 = (responder.lastTo?.value.instance?.underlyingInstance as? FR2)
        fr2?.proceedInWorkflow()

        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR3)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.value.instance?.underlyingInstance is FR2)
        XCTAssert((responder.lastFrom?.value.instance?.underlyingInstance as? FR2) === fr2)

        (responder.lastTo?.value.instance?.underlyingInstance as? FR3)?.proceedInWorkflow()

        wait(for: [FR2.expectation], timeout: 3)
    }

    func testWorkflowCanSkipMultipleItems_AndStillProceedThroughFlow_PassingThroughCorrectArgsToNextWorkflowItem() {
        final class FR1: TestFlowRepresentable<Never, String>, FlowRepresentable {
            static let id = UUID().uuidString
            func shouldLoad() -> Bool {
                proceedInWorkflow(FR1.id)
                return false
            }
        }
        class FR2: TestFlowRepresentable<String, String>, FlowRepresentable {
            let id: String
            required init(with id: String) {
                self.id = id
                XCTAssertEqual(id, FR1.id)
            }
            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad() -> Bool {
                FR2.expectation.fulfill()
                proceedInWorkflow(id)
                return false
            }
        }
        class FR3: TestFlowRepresentable<String, Never>, FlowRepresentable {
            required init(with id: String) { XCTAssertEqual(id, FR1.id) }
            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad() -> Bool {
                FR3.expectation.fulfill()
                return true
            }
        }
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self)
        let responder = MockOrchestrationResponder()

        let launchedRepresentable = wf.launch(withOrchestrationResponder: responder)

        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value.instance?.underlyingInstance is FR3)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR3)
        XCTAssertNil(responder.lastFrom)

        (responder.lastTo?.value.instance?.underlyingInstance as? FR3)?.proceedInWorkflow()

        wait(for: [FR2.expectation, FR3.expectation], timeout: 3)
    }

    func testWorkflowCanSkipFirstItem_AndStillProceedThroughFlow_PassingThroughInitialArgsToNextWorkflowItem() {
        class FR1: TestFlowRepresentable<String, String>, FlowRepresentable {
            required init(with args: String) { }
            static let id = UUID().uuidString
            func shouldLoad() -> Bool { false }
        }
        class FR2: TestFlowRepresentable<String, Never>, FlowRepresentable {
            required init(with id: String) { XCTAssertEqual(id, FR1.id) }

            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad() -> Bool {
                FR2.expectation.fulfill()
                return true
            }
        }
        class FR3: TestPassthroughFlowRepresentable { }
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self)
        let responder = MockOrchestrationResponder()

        let launchedRepresentable = wf.launch(withOrchestrationResponder: responder,
                                              args: FR1.id)

        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value.instance?.underlyingInstance is FR2)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR2)
        XCTAssertNil(responder.lastFrom)

        let fr2 = (responder.lastTo?.value.instance?.underlyingInstance as? FR2)
        fr2?.proceedInWorkflow()

        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR3)
        XCTAssertNotNil(responder.lastFrom)
        XCTAssert(responder.lastFrom?.value.instance?.underlyingInstance is FR2)
        XCTAssert((responder.lastFrom?.value.instance?.underlyingInstance as? FR2) === fr2)

        (responder.lastTo?.value.instance?.underlyingInstance as? FR3)?.proceedInWorkflow()

        wait(for: [FR2.expectation], timeout: 3)
    }

    func testWorkflowCanSkipMultipleItems_AndStillProceedThroughFlow_PassingThroughInitialArgsToNextWorkflowItem() {
        class FR1: TestFlowRepresentable<String, String>, FlowRepresentable {
            required init(with args: String) { }
            static let id = UUID().uuidString
            func shouldLoad() -> Bool { false }
        }
        class FR2: TestFlowRepresentable<String, String>, FlowRepresentable {
            required init(with id: String) { XCTAssertEqual(id, FR1.id) }
            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad() -> Bool {
                FR2.expectation.fulfill()
                return false
            }
        }
        class FR3: TestFlowRepresentable<String, Never>, FlowRepresentable {
            required init(with id: String) { XCTAssertEqual(id, FR1.id) }
            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad() -> Bool {
                FR3.expectation.fulfill()
                return true
            }
        }
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self)
        let responder = MockOrchestrationResponder()

        let launchedRepresentable = wf.launch(withOrchestrationResponder: responder, args: FR1.id)

        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value.instance?.underlyingInstance is FR3)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR3)
        XCTAssertNil(responder.lastFrom)

        (responder.lastTo?.value.instance?.underlyingInstance as? FR3)?.proceedInWorkflow()

        wait(for: [FR2.expectation, FR3.expectation], timeout: 3)
    }

    func testWorkflowCanSkipAllItems_AndStillProceedThroughFlow_PassingThroughInitialArgsToNextWorkflowItem() {
        class FR1: TestFlowRepresentable<String, String>, FlowRepresentable {
            required init(with id: String) { }
            static let id = UUID().uuidString
            func shouldLoad() -> Bool { false }
        }
        class FR2: TestFlowRepresentable<String, String>, FlowRepresentable {
            required init(with id: String) { XCTAssertEqual(id, FR1.id) }
            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad() -> Bool {
                FR2.expectation.fulfill()
                return false
            }
        }
        class FR3: TestFlowRepresentable<String, String>, FlowRepresentable {
            required init(with id: String) { XCTAssertEqual(id, FR1.id) }
            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad() -> Bool {
                FR3.expectation.fulfill()
                return false
            }
        }
        let expectation = self.expectation(description: "onFinish called")
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self)
        let responder = MockOrchestrationResponder()

        let launchedRepresentable = wf.launch(withOrchestrationResponder: responder, args: FR1.id) { id in
            expectation.fulfill()
            XCTAssertEqual(id.extractArgs(defaultValue: nil) as? String, FR1.id)
        }

        XCTAssertEqual(responder.proceedCalled, 0)
        XCTAssertNil(launchedRepresentable)
        XCTAssertNil(responder.lastTo)
        XCTAssertNil(responder.lastFrom)

        wait(for: [FR2.expectation, FR3.expectation, expectation], timeout: 3)
    }

    func testWorkflowCanSkipMiddleItem_AndStillProceedThroughFlow_PassingThroughCorrectArgsToNextWorkflowItem() {
        final class FR1: TestFlowRepresentable<Never, String>, FlowRepresentable {
            static let id = UUID().uuidString
        }
        class FR2: TestFlowRepresentable<String, String>, FlowRepresentable {
            let id: String
            required init(with id: String) {
                self.id = id
                XCTAssertEqual(id, FR1.id)
            }
            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad() -> Bool {
                FR2.expectation.fulfill()
                proceedInWorkflow(id)
                return false
            }
        }
        class FR3: TestFlowRepresentable<String, Never>, FlowRepresentable {
            required init(with id: String) { XCTAssertEqual(id, FR1.id) }
            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad() -> Bool {
                FR3.expectation.fulfill()
                return true
            }
        }
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self)
        let responder = MockOrchestrationResponder()

        let launchedRepresentable = wf.launch(withOrchestrationResponder: responder)

        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value.instance?.underlyingInstance is FR1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR1)
        XCTAssertNil(responder.lastFrom)

        (responder.lastTo?.value.instance?.underlyingInstance as? FR1)?.proceedInWorkflow(FR1.id)

        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR3)
        XCTAssert(responder.lastFrom?.value.instance?.underlyingInstance is FR1)

        wait(for: [FR2.expectation, FR3.expectation], timeout: 3)
    }

    func testWorkflowCanSkipAllExceptTheFirstItem_AndStillProceedThroughFlow_PassingThroughCorrectArgsToNextWorkflowItem() {
        final class FR1: TestFlowRepresentable<Never, String>, FlowRepresentable {
            static let id = UUID().uuidString
        }
        class FR2: TestFlowRepresentable<String, String>, FlowRepresentable {
            let id: String
            required init(with id: String) {
                self.id = id
                XCTAssertEqual(id, FR1.id)
            }
            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad() -> Bool {
                FR2.expectation.fulfill()
                proceedInWorkflow(id)
                return false
            }
        }
        class FR3: TestFlowRepresentable<String, String>, FlowRepresentable {
            let id: String
            required init(with id: String) {
                self.id = id
                XCTAssertEqual(id, FR1.id)
            }
            static let expectation = XCTestExpectation(description: "shouldLoad called")
            func shouldLoad() -> Bool {
                FR3.expectation.fulfill()
                proceedInWorkflow(id)
                return false
            }
        }
        let expectation = self.expectation(description: "onFinish called")
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self)
        let responder = MockOrchestrationResponder()
        responder.complete_EnableDefaultImplementation = true

        let launchedRepresentable = wf.launch(withOrchestrationResponder: responder) { id in
            expectation.fulfill()
            XCTAssertEqual(id.extractArgs(defaultValue: nil) as? String, FR1.id)
        }

        XCTAssertEqual(responder.launchCalled, 1)
        XCTAssert(launchedRepresentable?.value.instance?.underlyingInstance is FR1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR1)
        XCTAssertNil(responder.lastFrom)
        XCTAssertEqual(responder.completeCalled, 0)

        (launchedRepresentable?.value.instance?.underlyingInstance as? FR1)?.proceedInWorkflow(FR1.id)

        XCTAssertEqual(responder.completeCalled, 1)
        wait(for: [FR2.expectation, FR3.expectation, expectation], timeout: 3)
    }
}

extension SkipThroughWorkflowTests {
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
