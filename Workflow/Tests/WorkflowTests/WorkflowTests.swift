//
//  WorkflowTests.swift
//  WorkflowTests
//
//  Created by Tyler Thompson on 8/25/19.
//  Copyright © 2019 Tyler Tompson. All rights reserved.
//
import XCTest

@testable import Workflow

class WorkflowTests: XCTestCase {
    func testFlowRepresentablesWithMultipleTypesCanBeStoredAndRetreived() {
        class FR1: FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?
            
            static var shouldLoadCalledOnFR1 = false
            typealias WorkflowInput = String
            typealias WorkflowOutput = Int
            
            static func instance() -> Self { FR1() as! Self }
            
            func shouldLoad(with args: String) -> Bool {
                FR1.shouldLoadCalledOnFR1 = true
                return true
            }
        }
        class FR2: FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?
            
            static var shouldLoadCalledOnFR2 = false
            typealias WorkflowInput = Int
            
            static func instance() -> Self { FR2() as! Self }
            
            func shouldLoad(with args: Int) -> Bool {
                FR2.shouldLoadCalledOnFR2 = true
                return true
            }
        }
        let flow = Workflow(FR1.self).thenPresent(FR2.self)
        let first = flow.first?.value.flowRepresentableFactory()
        let last = flow.last?.value.flowRepresentableFactory()
        _ = first?.shouldLoad(with: "str")
        _ = last?.shouldLoad(with: 1)
        
        XCTAssert(FR1.shouldLoadCalledOnFR1, "Should load not called on flow representable 1 with correct corresponding type")
        XCTAssert(FR2.shouldLoadCalledOnFR2, "Should load not called on flow representable 2 with correct corresponding type")
    }
    
    func testFlowRepresentablesThatDefineAWorkflowInputOfOptionalAnyDoesNotRecurseForever() {
        class FR1: FlowRepresentable {
            func shouldLoad(with args: Any?) -> Bool { true }
            
            weak var _workflowPointer: AnyFlowRepresentable?
            
            static var shouldLoadCalledOnFR1 = false
            typealias WorkflowInput = Any?
            
            static func instance() -> Self { FR1() as! Self }
        }
        
        let instance = AnyFlowRepresentable(FR1.instance())
        XCTAssert(instance.shouldLoad(with: "str") == true)
    }

    func testProgressToNextAvailableItemInWorkflow() {
        class FR1: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            static func instance() -> Self { Self() }
        }
        class FR2: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            static func instance() -> Self { Self() }
            func shouldLoad() -> Bool { false }
        }
        class FR3: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            static func instance() -> Self { Self() }
        }

        let responder = MockOrchestrationResponder()
        let wf = Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)

        wf.applyOrchestrationResponder(responder)

        let firstInstance = wf.launch(with: 1)
        XCTAssert(firstInstance?.value?.underlyingInstance is FR1)
        XCTAssertNil(responder.lastFrom)
        XCTAssert(responder.lastTo?.instance.value?.underlyingInstance is FR1)
        XCTAssert((responder.lastTo?.instance.value?.underlyingInstance as? FR1) === firstInstance?.value?.underlyingInstance as? FR1)
        XCTAssertEqual(responder.launchCalled, 1)
        (firstInstance?.value?.underlyingInstance as? FR1)?.proceedInWorkflow()
        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert((responder.lastFrom?.instance.value?.underlyingInstance as? FR1) === firstInstance?.value?.underlyingInstance as? FR1)
        XCTAssert(responder.lastTo?.instance.value?.underlyingInstance is FR3)
        XCTAssert((responder.lastTo?.instance.value?.underlyingInstance as? FR3) === firstInstance?.next?.next?.value?.underlyingInstance as? FR3)
    }
    
    func testWorkflowReturnsNilWhenLaunchingWithoutRepresentables() {
        let wf:AnyWorkflow = AnyWorkflow()
        XCTAssertNil(wf.launch(with: nil))
    }

    func testWorkflowCallsBackOnCompletion() {
        class FR1: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            typealias WorkflowOutput = String
            static func instance() -> Self { Self() }
        }
        class FR2: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            typealias WorkflowOutput = String
            static func instance() -> Self { Self() }
        }

        let wf:Workflow = Workflow(FR1.self)
            .thenPresent(FR2.self)

        var callbackCalled = false
        let firstInstance = wf.launch(with: 1) { args in
            callbackCalled = true
            XCTAssertEqual(args as? String, "args")
        }
        XCTAssert(firstInstance?.value?.underlyingInstance is FR1)
        (firstInstance?.value?.underlyingInstance as? FR1)?.proceedInWorkflow("test")
        (firstInstance?.next?.value?.underlyingInstance as? FR2)?.proceedInWorkflow("args")
        XCTAssert(callbackCalled)
    }

    func testWorkflowCallsBackOnCompletionWhenLastViewIsSkipped() {
        class FR1: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            typealias WorkflowOutput = String
            static func instance() -> Self { Self() }
        }
        class FR2: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            typealias WorkflowOutput = String
            static func instance() -> Self { Self() }

            func shouldLoad() -> Bool {
                proceedInWorkflow("args")
                return false
            }
        }

        let wf:Workflow = Workflow(FR1.self)
            .thenPresent(FR2.self)

        var callbackCalled = false
        let firstInstance = wf.launch(with: 1) { args in
            callbackCalled = true
            XCTAssertEqual(args as? String, "args")
        }
        XCTAssert(firstInstance?.value?.underlyingInstance is FR1)
        (firstInstance?.value?.underlyingInstance as? FR1)?.proceedInWorkflow("test")
        XCTAssert(callbackCalled)
    }

    func testWorkflowCallsBackOnCompletionWhenLastViewIsSkipped_AndItIsTheOnlyView() {
        class FR1: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            typealias WorkflowOutput = String
            static func instance() -> Self { Self() }
            func shouldLoad() -> Bool {
                proceedInWorkflow("args")
                return false
            }
        }

        let wf:Workflow = Workflow(FR1.self)

        var callbackCalled = false
        _ = wf.launch(with: 1) { args in
            callbackCalled = true
            XCTAssertEqual(args as? String, "args")
        }
        XCTAssert(callbackCalled)
    }
    
    class TestFlowRepresentable<I, O> {
        typealias WorkflowInput = I
        typealias WorkflowOutput = O
        
        required init() { }
        
        weak var _workflowPointer: AnyFlowRepresentable?
    }
}
