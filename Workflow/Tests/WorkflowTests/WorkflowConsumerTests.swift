//
//  WorkflowConsumerTests.swift
//  WorkflowTests
//
//  Created by Tyler Thompson on 8/25/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest

import Workflow

class WorkflowConsumerTests: XCTestCase {
    func testProgressToNextAvailableItemInWorkflow() {
        class FR1: TestFlowRepresentable<Never, Never>, FlowRepresentable { }
        class FR2: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            func shouldLoad() -> Bool { false }
        }
        class FR3: TestFlowRepresentable<Never, Never>, FlowRepresentable { }

        let responder = MockOrchestrationResponder()
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self)

        wf.applyOrchestrationResponder(responder)

        let firstInstance = wf.launch(with: 1)
        XCTAssert(firstInstance?.value.instance?.underlyingInstance is FR1)
        XCTAssertNil(responder.lastFrom)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR1)
        XCTAssert((responder.lastTo?.value.instance?.underlyingInstance as? FR1) === firstInstance?.value.instance?.underlyingInstance as? FR1)
        XCTAssertEqual(responder.launchCalled, 1)
        (firstInstance?.value.instance?.underlyingInstance as? FR1)?.proceedInWorkflow()
        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert((responder.lastFrom?.value.instance?.underlyingInstance as? FR1) === firstInstance?.value.instance?.underlyingInstance as? FR1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR3)
        XCTAssert((responder.lastTo?.value.instance?.underlyingInstance as? FR3) === firstInstance?.next?.next?.value.instance?.underlyingInstance as? FR3)
    }

    func testProgressToNextAvailableItemInWorkflowWithValueTypes() {
        struct FR1: FlowRepresentable {
            typealias WorkflowInput = Never
            typealias WorkflowOutput = Never
            var _workflowPointer: AnyFlowRepresentable?
            static func instance() -> Self { Self() }
        }
        struct FR2: FlowRepresentable {
            typealias WorkflowInput = Never
            typealias WorkflowOutput = Never
            var _workflowPointer: AnyFlowRepresentable?
            static func instance() -> Self { Self() }
        }
        struct FR3: FlowRepresentable {
            typealias WorkflowInput = Never
            typealias WorkflowOutput = Never
            var _workflowPointer: AnyFlowRepresentable?
            static func instance() -> Self { Self() }
        }

        let responder = MockOrchestrationResponder()
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self)

        wf.applyOrchestrationResponder(responder)

        let firstInstance = wf.launch(with: 1)
        XCTAssert(firstInstance?.value.instance?.underlyingInstance is FR1)
        XCTAssertNil(responder.lastFrom)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR1)
        XCTAssertEqual(responder.launchCalled, 1)
        (responder.lastTo?.value.instance?.underlyingInstance as? FR1)?.proceedInWorkflow()
        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR2)
        (responder.lastTo?.value.instance?.underlyingInstance as? FR2)?.proceedInWorkflow()
        XCTAssertEqual(responder.proceedCalled, 2)
        XCTAssert(responder.lastFrom?.value.instance?.underlyingInstance is FR2)
        XCTAssert(responder.lastTo?.value.instance?.underlyingInstance is FR3)
    }

    func testBackUpThrowsErrorIfAtBeginningOfWorkflow() {
        struct FR1: FlowRepresentable {
            typealias WorkflowInput = Never
            var _workflowPointer: AnyFlowRepresentable?
        }

        let responder = MockOrchestrationResponder()
        let wf = Workflow(FR1.self)
        wf.applyOrchestrationResponder(responder)
        wf.launch()

        XCTAssertThrowsError(try (responder.lastTo?.value.instance?.underlyingInstance as? FR1)?.backUpInWorkflow()) { actualError in
            XCTAssertNotNil(actualError as? WorkflowError, "Expected \(actualError) to be WorkflowError")
            XCTAssertEqual(actualError as? WorkflowError, .failedToBackUp, "Expected \(actualError) to be failedToBackUp")
        }
    }

    func testWorkflowReturnsNilWhenLaunchingWithoutRepresentables() {
        let wf: AnyWorkflow = AnyWorkflow()
        XCTAssertNil(wf.launch())
        XCTAssertNil(wf.launch(with: nil))
    }

    func testWorkflowCallsBackOnCompletion() {
        class FR1: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            typealias WorkflowOutput = String
        }
        class FR2: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            typealias WorkflowOutput = String
        }

        let wf: Workflow = Workflow(FR1.self)
            .thenProceed(with: FR2.self)

        var callbackCalled = false
        let firstInstance = wf.launch(with: 1) { args in
            callbackCalled = true
            XCTAssertEqual(args.extractArgs(defaultValue: nil) as? String, "args")
        }
        XCTAssert(firstInstance?.value.instance?.underlyingInstance is FR1)
        (firstInstance?.value.instance?.underlyingInstance as? FR1)?.proceedInWorkflow("test")
        (firstInstance?.next?.value.instance?.underlyingInstance as? FR2)?.proceedInWorkflow("args")
        XCTAssert(callbackCalled)
    }

    func testWorkflowCallsBackOnCompletionWhenLastViewIsSkipped() {
        class FR1: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            typealias WorkflowOutput = String
        }
        class FR2: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            typealias WorkflowOutput = String
            func shouldLoad() -> Bool {
                proceedInWorkflow("args")
                return false
            }
        }

        let wf: Workflow = Workflow(FR1.self)
            .thenProceed(with: FR2.self)

        var callbackCalled = false
        let firstInstance = wf.launch(with: 1) { args in
            callbackCalled = true
            XCTAssertEqual(args.extractArgs(defaultValue: nil) as? String, "args")
        }
        XCTAssert(firstInstance?.value.instance?.underlyingInstance is FR1)
        (firstInstance?.value.instance?.underlyingInstance as? FR1)?.proceedInWorkflow("test")
        XCTAssert(callbackCalled)
    }

    func testWorkflowCallsBackOnCompletionWhenLastViewIsSkipped_AndItIsTheOnlyView() {
        class FR1: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            typealias WorkflowOutput = String
            func shouldLoad() -> Bool {
                proceedInWorkflow("args")
                return false
            }
        }

        let wf: Workflow = Workflow(FR1.self)

        var callbackCalled = false
        _ = wf.launch(with: 1) { args in
            callbackCalled = true
            XCTAssertEqual(args.extractArgs(defaultValue: nil) as? String, "args")
        }
        XCTAssert(callbackCalled)
    }
}

extension WorkflowConsumerTests {
    class TestFlowRepresentable<I, O> {
        typealias WorkflowInput = I
        typealias WorkflowOutput = O

        required init() { }

        static func instance() -> Self { Self() }

        weak var _workflowPointer: AnyFlowRepresentable?
    }
}
