//
//  GenericConstraintTests.swift
//  SwiftCurrentTests
//
//  Created by Tyler Thompson on 7/24/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest

import SwiftCurrent

final class GenericConstraintTests: XCTestCase {
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
