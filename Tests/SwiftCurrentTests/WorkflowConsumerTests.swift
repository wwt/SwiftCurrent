//
//  WorkflowConsumerTests.swift
//  WorkflowTests
//
//  Created by Tyler Thompson on 8/25/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest

import SwiftCurrent

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
        let responder = MockOrchestrationResponder()
        responder.complete_EnableDefaultImplementation = true
        wf.launch(withOrchestrationResponder: responder, args: 1) { args in
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

    // MARK: Generic Initializer Tests

    // MARK: Input Type == Never

    func testWhenInputIsNever_FlowPersistenceCanBeSetWithAutoclosure() {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self, flowPersistence: .persistWhenSkipped)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testWhenInputIsNever_FlowPersistenceCanBeSetWithClosure() {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let expectedArgs = UUID().uuidString

        let expectation = self.expectation(description: "FlowPersistence closure called")
        let wf = Workflow(FR1.self, flowPersistence: {
            defer { expectation.fulfill() }
            return .persistWhenSkipped
        })

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToAnotherNeverItem() throws {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToAnotherNeverItem() throws {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self, flowPersistence: .persistWhenSkipped).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToAnotherNeverItem() throws {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self, flowPersistence: { .persistWhenSkipped }).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self, flowPersistence: .persistWhenSkipped).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self, flowPersistence: { .persistWhenSkipped }).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow(1)
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self, flowPersistence: .persistWhenSkipped).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow(1)
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self, flowPersistence: { .persistWhenSkipped }).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow(1)
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }


    // MARK: Input Type == AnyWorkflow.PassedArgs

    func testWhenInputIsAnyWorkflowPassedArgs_FlowPersistenceCanBeSetWithAutoclosure() {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self, flowPersistence: .persistWhenSkipped)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testWhenInputIsAnyWorkflowPassedArgs_FlowPersistenceCanBeSetWithClosure() {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let expectation = self.expectation(description: "FlowPersistence closure called")
        let wf = Workflow(FR1.self, flowPersistence: {
            XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
            defer { expectation.fulfill() }
            return .persistWhenSkipped
        })

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToNeverItem() throws {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToNeverItem() throws {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self, flowPersistence: .persistWhenSkipped).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToNeverItem() throws {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self, flowPersistence: {
            XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
            return .persistWhenSkipped
        }).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self, flowPersistence: .persistWhenSkipped).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self, flowPersistence: {
            XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
            return .persistWhenSkipped
        }).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow(1)
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self, flowPersistence: .persistWhenSkipped).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow(1)
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self, flowPersistence: {
            XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
            return .persistWhenSkipped
        }).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow(1)
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    // MARK: Input Type == Concrete Type
    func testWhenInputIsConcreteType_FlowPersistenceCanBeSetWithAutoclosure() {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self, flowPersistence: .persistWhenSkipped)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testWhenInputIsConcreteType_FlowPersistenceCanBeSetWithClosure() {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let expectation = self.expectation(description: "FlowPersistence closure called")
        let wf = Workflow(FR1.self, flowPersistence: {
            XCTAssertEqual($0, expectedArgs)
            defer { expectation.fulfill() }
            return .persistWhenSkipped
        })

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testWhenInputIsConcreteTypeWithDefaultFlowPersistence_WorkflowCanProceedToNeverItem() throws {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToNeverItem() throws {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self, flowPersistence: .persistWhenSkipped).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToNeverItem() throws {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self, flowPersistence: {
            XCTAssertEqual($0, expectedArgs)
            return .persistWhenSkipped
        }).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsConcreteTypeWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self, flowPersistence: .persistWhenSkipped).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self, flowPersistence: {
            XCTAssertEqual($0, expectedArgs)
            return .persistWhenSkipped
        }).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsConcreteTypeArgsWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow(1)
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self, flowPersistence: .persistWhenSkipped).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow(1)
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self, flowPersistence: {
            XCTAssertEqual($0, expectedArgs)
            return .persistWhenSkipped
        }).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow(1)
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsConcreteTypeArgsWithDefaultFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() throws {
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = String
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow("")
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() throws {
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = String
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self, flowPersistence: .persistWhenSkipped).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow("")
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() throws {
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = String
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR1.self, flowPersistence: {
            XCTAssertEqual($0, expectedArgs)
            return .persistWhenSkipped
        }).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow("")
        XCTAssert(wf.first?.next?.value.instance?.underlyingInstance is FR2)
    }

    // MARK: Generic Proceed Tests

    // MARK: Input Type == Never

    func testProceedingWhenInputIsNever_FlowPersistenceCanBeSetWithAutoclosure() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self, flowPersistence: .persistWhenSkipped)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        XCTAssertEqual(wf.first?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingWhenInputIsNever_FlowPersistenceCanBeSetWithClosure() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let expectedArgs = UUID().uuidString

        let expectation = self.expectation(description: "FlowPersistence closure called")
        let wf = Workflow(FR0.self).thenProceed(with: FR1.self, flowPersistence: {
            defer { expectation.fulfill() }
            return .persistWhenSkipped
        })

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(wf.first?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToAnotherNeverItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testProceedingWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToAnotherNeverItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self, flowPersistence: .persistWhenSkipped)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
        XCTAssertEqual(wf.first?.next?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToAnotherNeverItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self, flowPersistence: { .persistWhenSkipped })

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
        XCTAssertEqual(wf.first?.next?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testProceedingWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self, flowPersistence: .persistWhenSkipped)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
        XCTAssertEqual(wf.first?.next?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self, flowPersistence: { _ in .persistWhenSkipped })

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
        XCTAssertEqual(wf.first?.next?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow(1)
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testProceedingWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self, flowPersistence: .persistWhenSkipped)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow(1)
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
        XCTAssertEqual(wf.first?.next?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self, flowPersistence: {
            XCTAssertEqual($0, 1)
            return .persistWhenSkipped
        })

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow(1)
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
        XCTAssertEqual(wf.first?.next?.next?.value.metadata.persistence, .persistWhenSkipped)
    }


    // MARK: Input Type == AnyWorkflow.PassedArgs

    func testProceedingWhenInputIsAnyWorkflowPassedArgs_FlowPersistenceCanBeSetWithAutoclosure() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self, flowPersistence: .persistWhenSkipped)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        XCTAssertEqual(wf.first?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgs_FlowPersistenceCanBeSetWithClosure() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let expectation = self.expectation(description: "FlowPersistence closure called")
        let wf = Workflow(FR0.self).thenProceed(with: FR1.self, flowPersistence: {
            XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
            defer { expectation.fulfill() }
            return .persistWhenSkipped
        })

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(wf.first?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToNeverItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToNeverItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self, flowPersistence: .persistWhenSkipped)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
        XCTAssertEqual(wf.first?.next?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToNeverItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self, flowPersistence: {
            XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
            return .persistWhenSkipped
        }).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        XCTAssertEqual(wf.first?.next?.value.metadata.persistence, .persistWhenSkipped)
        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self, flowPersistence: .persistWhenSkipped)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
        XCTAssertEqual(wf.first?.next?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self, flowPersistence: {
            XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
            return .persistWhenSkipped
        })

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
        XCTAssertEqual(wf.first?.next?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow(1)
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self, flowPersistence: .persistWhenSkipped)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow(1)
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
        XCTAssertEqual(wf.first?.next?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self, flowPersistence: {
            XCTAssertEqual($0, 1)
            return .persistWhenSkipped
        })

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow(1)
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
        XCTAssertEqual(wf.first?.next?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    // MARK: Input Type == Concrete Type
    func testProceedingWhenInputIsConcreteType_FlowPersistenceCanBeSetWithAutoclosure() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self, flowPersistence: .persistWhenSkipped)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        XCTAssertEqual(wf.first?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingWhenInputIsConcreteType_FlowPersistenceCanBeSetWithClosure() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let expectation = self.expectation(description: "FlowPersistence closure called")
        let wf = Workflow(FR0.self).thenProceed(with: FR1.self, flowPersistence: {
            XCTAssertEqual($0, expectedArgs)
            defer { expectation.fulfill() }
            return .persistWhenSkipped
        })

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(wf.first?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingWhenInputIsConcreteTypeWithDefaultFlowPersistence_WorkflowCanProceedToNeverItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testProceedingWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToNeverItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self, flowPersistence: .persistWhenSkipped)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
        XCTAssertEqual(wf.first?.next?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToNeverItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self, flowPersistence: { .persistWhenSkipped })

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
        XCTAssertEqual(wf.first?.next?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingWhenInputIsConcreteTypeWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testProceedingWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self, flowPersistence: .persistWhenSkipped)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
        XCTAssertEqual(wf.first?.next?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self, flowPersistence: { _ in .persistWhenSkipped })

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow()
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
        XCTAssertEqual(wf.first?.next?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingWhenInputIsConcreteTypeArgsWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow(1)
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testProceedingWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self, flowPersistence: .persistWhenSkipped)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow(1)
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
        XCTAssertEqual(wf.first?.next?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self, flowPersistence: {
            XCTAssertEqual($0, 1)
            return .persistWhenSkipped
        })

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow(1)
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
        XCTAssertEqual(wf.first?.next?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingWhenInputIsConcreteTypeArgsWithDefaultFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = String
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow("")
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
    }

    func testProceedingWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = String
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self, flowPersistence: .persistWhenSkipped)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow("")
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
        XCTAssertEqual(wf.first?.next?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = String
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self, flowPersistence: { _ in .persistWhenSkipped })

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow("")
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
        XCTAssertEqual(wf.first?.next?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToAnyWorkflowPassedArgsItem() throws {
        struct FR0: PassthroughFlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR1: FlowRepresentable {
            typealias WorkflowOutput = String
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable {
            var _workflowPointer: AnyFlowRepresentable?
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let wf = Workflow(FR0.self).thenProceed(with: FR1.self).thenProceed(with: FR2.self, flowPersistence: .persistWhenSkipped)

        wf.launch(withOrchestrationResponder: MockOrchestrationResponder(), args: expectedArgs)
        try XCTUnwrap(wf.first?.value.instance?.underlyingInstance as? FR0).proceedInWorkflow()

        try XCTUnwrap(wf.first?.next?.value.instance?.underlyingInstance as? FR1).proceedInWorkflow(expectedArgs)
        XCTAssert(wf.first?.next?.next?.value.instance?.underlyingInstance is FR2)
        XCTAssertEqual(wf.first?.next?.next?.value.metadata.persistence, .persistWhenSkipped)
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
