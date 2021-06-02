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

        let firstInstance = wf.launch(withOrchestrationResponder: responder, args: 1)
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
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR3: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }

        let responder = MockOrchestrationResponder()
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self)

        let firstInstance = wf.launch(withOrchestrationResponder: responder, args: 1)
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
            var _workflowPointer: AnyFlowRepresentable?
        }

        let responder = MockOrchestrationResponder()
        let wf = Workflow(FR1.self)
        wf.launch(withOrchestrationResponder: responder)

        XCTAssertThrowsError(try (responder.lastTo?.value.instance?.underlyingInstance as? FR1)?.backUpInWorkflow()) { actualError in
            XCTAssertNotNil(actualError as? WorkflowError, "Expected \(actualError) to be WorkflowError")
            XCTAssertEqual(actualError as? WorkflowError, .failedToBackUp, "Expected \(actualError) to be failedToBackUp")
        }
    }

    func testWorkflowReturnsNilWhenLaunchingWithoutRepresentables() {
        final class FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let wf = Workflow<FR1>()
        XCTAssertNil(wf.launch(withOrchestrationResponder: MockOrchestrationResponder()))
        XCTAssertNil(wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: nil))
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
        let responder = MockOrchestrationResponder()
        responder.complete_EnableDefaultImplementation = true

        var callbackCalled = false
        let firstInstance = wf.launch(withOrchestrationResponder: responder, args: 1) { args in
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
        let responder = MockOrchestrationResponder()
        responder.complete_EnableDefaultImplementation = true

        var callbackCalled = false
        let firstInstance = wf.launch(withOrchestrationResponder: responder, args: 1) { args in
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
        _ = wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: 1) { args in
            callbackCalled = true
            XCTAssertEqual(args.extractArgs(defaultValue: nil) as? String, "args")
        }
        XCTAssert(callbackCalled)
    }

    func testWorkflowWithSeveralBackToBackPersistWhenSkippedItems_StillCallsOrchestrationResponderAppropriately() {
        final class FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }

        final class FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            func shouldLoad() -> Bool { false }
        }

        final class FR3: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            func shouldLoad() -> Bool { false }
        }

        final class FR4: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }

        let mockOrchestrationResponder = MockOrchestrationResponder()
        let workflow = Workflow(FR1.self)
            .thenProceed(with: FR2.self, flowPersistence: .persistWhenSkipped)
            .thenProceed(with: FR3.self, flowPersistence: .persistWhenSkipped)
            .thenProceed(with: FR4.self)

        workflow.launch(withOrchestrationResponder: mockOrchestrationResponder)

        XCTAssertEqual(mockOrchestrationResponder.launchCalled, 1)
        XCTAssert(mockOrchestrationResponder.lastTo?.value.instance?.underlyingInstance is FR1)

        (workflow.first?.value.instance?.underlyingInstance as? FR1)?.proceedInWorkflow()

        XCTAssertEqual(mockOrchestrationResponder.allTos.count, 4)
        XCTAssertEqual(mockOrchestrationResponder.allFroms.count, 3)

        guard mockOrchestrationResponder.allTos.count == 4, mockOrchestrationResponder.allFroms.count == 3 else { return }

        XCTAssert(mockOrchestrationResponder.allFroms[0].value.instance?.underlyingInstance is FR1, "Expected orchestration responder to proceed from FR1, but was: \(String(describing: mockOrchestrationResponder.allFroms[0].value.instance?.underlyingInstance))")
        XCTAssert(mockOrchestrationResponder.allTos[1].value.instance?.underlyingInstance is FR2, "Expected orchestration responder to proceed to FR2, but was: \(String(describing: mockOrchestrationResponder.allTos[1].value.instance?.underlyingInstance))")

        XCTAssert(mockOrchestrationResponder.allFroms[1].value.instance?.underlyingInstance is FR2, "Expected orchestration responder to proceed from FR2, but was: \(String(describing: mockOrchestrationResponder.allFroms[1].value.instance?.underlyingInstance))")
        XCTAssert(mockOrchestrationResponder.allTos[2].value.instance?.underlyingInstance is FR3, "Expected orchestration responder to proceed to FR3, but was: \(String(describing: mockOrchestrationResponder.allTos[2].value.instance?.underlyingInstance))")

        XCTAssert(mockOrchestrationResponder.allFroms[2].value.instance?.underlyingInstance is FR3, "Expected orchestration responder to proceed from FR3, but was: \(String(describing: mockOrchestrationResponder.allFroms[2].value.instance?.underlyingInstance))")
        XCTAssert(mockOrchestrationResponder.allTos[3].value.instance?.underlyingInstance is FR4, "Expected orchestration responder to proceed to FR4, but was: \(String(describing: mockOrchestrationResponder.allTos[3].value.instance?.underlyingInstance))")
    }

    func testWorkflowCanBeInitialized_WithFlowPersistenceClosure() {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with name: String) { }
        }
        let expectation = self.expectation(description: "FlowPersistence closure called")
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self) { args in
            XCTAssertEqual(args, expectedArgs)
            expectation.fulfill()
            return .persistWhenSkipped
        }

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(),
                  args: expectedArgs)

        wait(for: [expectation], timeout: 0.1)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testWorkflowThrowsFatalError_WhenLaunchedWithWrongArgumentType() {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with name: String) { }
        }

        let wf = Workflow(FR1.self) { args in .default }

        XCTAssertThrowsFatalError {
            wf.launch(withOrchestrationResponder: MockOrchestrationResponder(),
                      args: 1)
        }
    }

    func testWorkflowCanBeInitialized_WithFlowPersistenceClosure_WhenTheFirstItemHasNoInput() {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let expectation = self.expectation(description: "FlowPersistence closure called")
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self) {
            expectation.fulfill()
            return .persistWhenSkipped
        }

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(),
                  args: expectedArgs)

        wait(for: [expectation], timeout: 0.1)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testWorkflowCanBeInitialized_WithFlowPersistenceClosure_WhenTheFirstItemHasPassedArgsInput() {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectation = self.expectation(description: "FlowPersistence closure called")
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self) { args in
            expectation.fulfill()
            XCTAssertEqual(args.extractArgs(defaultValue: nil) as? String, expectedArgs)
            return .persistWhenSkipped
        }

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(),
                  args: expectedArgs)

        wait(for: [expectation], timeout: 0.1)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testWorkflowCanProceed_WithFlowPersistenceAutoClosure_WhenTheFirstItemHasPassedArgsInput() {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self, flowPersistence: .persistWhenSkipped)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder())

        (wf.first?.value.instance?.underlyingInstance as? FR1)?.proceedInWorkflow()

        XCTAssertEqual(wf.first?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testWorkflowCanProceed_WithFlowPersistenceClosure() {
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = String
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with name: String) { }
        }
        let expectation = self.expectation(description: "FlowPersistence closure called")
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self) { args in
                XCTAssertEqual(args, expectedArgs)
                expectation.fulfill()
                return .persistWhenSkipped
            }

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder())

        (wf.first?.value.instance?.underlyingInstance as? FR1)?.proceedInWorkflow(expectedArgs)

        wait(for: [expectation], timeout: 0.1)

        XCTAssertEqual(wf.first?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testWorkflowCanProceed_WithFlowPersistenceAutoClosure_WhenRepresentableHasInputOfPassedArgs() {
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = String
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with name: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self, flowPersistence: .persistWhenSkipped)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder())

        (wf.first?.value.instance?.underlyingInstance as? FR1)?.proceedInWorkflow(expectedArgs)

        XCTAssertEqual(wf.first?.next?.value.metadata.persistence, .persistWhenSkipped)
    }
}

extension WorkflowConsumerTests {
    class TestFlowRepresentable<I, O> {
        typealias WorkflowInput = I
        typealias WorkflowOutput = O

        required init() { }

        weak var _workflowPointer: AnyFlowRepresentable?
    }
}
