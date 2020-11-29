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
        struct FR1: FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?
            
            static var shouldLoadCalledOnFR1 = false
            typealias WorkflowInput = String
            typealias WorkflowOutput = Int
            
            static func instance() -> Self { Self() }
            
            func shouldLoad(with args: String) -> Bool {
                FR1.shouldLoadCalledOnFR1 = true
                return true
            }
        }
        struct FR2: FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?
            
            static var shouldLoadCalledOnFR2 = false
            typealias WorkflowInput = Int
            
            static func instance() -> Self { Self() }
            
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

        var fr1 = FR1.instance()
        let instance = AnyFlowRepresentable(&fr1)
        XCTAssert(instance.shouldLoad(with: "str") == true)
    }

    func testProgressToNextAvailableItemInWorkflow() {
        class FR1: TestFlowRepresentable<Never, Never>, FlowRepresentable { }
        class FR2: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            func shouldLoad() -> Bool { false }
        }
        class FR3: TestFlowRepresentable<Never, Never>, FlowRepresentable { }

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
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)

        wf.applyOrchestrationResponder(responder)

        let firstInstance = wf.launch(with: 1)
        XCTAssert(firstInstance?.value?.underlyingInstance is FR1)
        XCTAssertNil(responder.lastFrom)
        XCTAssert(responder.lastTo?.instance.value?.underlyingInstance is FR1)
        XCTAssertEqual(responder.launchCalled, 1)
        (responder.lastTo?.instance.value?.underlyingInstance as? FR1)?.proceedInWorkflow()
        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert(responder.lastTo?.instance.value?.underlyingInstance is FR2)
        (responder.lastTo?.instance.value?.underlyingInstance as? FR2)?.proceedInWorkflow()
        XCTAssertEqual(responder.proceedCalled, 2)
        XCTAssert(responder.lastFrom?.instance.value?.underlyingInstance is FR2)
        XCTAssert(responder.lastTo?.instance.value?.underlyingInstance is FR3)
    }

    func testProceedBackwardThrowsFatalErrorIfInternalStateIsMangled() {
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
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)

        wf.applyOrchestrationResponder(responder)

        wf.launch(with: 1)

        (responder.lastTo?.instance.value?.underlyingInstance as? FR1)?.proceedInWorkflow()

        wf.first = nil

        XCTAssertThrowsFatalError {
            (responder.lastTo?.instance.value?.underlyingInstance as? FR2)?.proceedBackwardInWorkflow()
        }
    }
    
    func testWorkflowReturnsNilWhenLaunchingWithoutRepresentables() {
        let wf:AnyWorkflow = AnyWorkflow()
        XCTAssertNil(wf.launch(with: nil))
    }

    func testWorkflowCallsBackOnCompletion() {
        class FR1: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            typealias WorkflowOutput = String
        }
        class FR2: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            typealias WorkflowOutput = String
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
        }
        class FR2: TestFlowRepresentable<Never, Never>, FlowRepresentable {
            typealias WorkflowOutput = String
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

    func testAnyFlowRepresentableThrowsFatalErrorIfItSomehowHasATypeMismatch() {
        class FR1: TestFlowRepresentable<String, Int>, FlowRepresentable {
            func shouldLoad(with args: String) -> Bool { true }
        }

        var instance = FR1()
        let rep = AnyFlowRepresentable(&instance)

        XCTAssertThrowsFatalError {
            _ = rep.shouldLoad(with: 10.23)
        }
    }
    
    class TestFlowRepresentable<I, O> {
        typealias WorkflowInput = I
        typealias WorkflowOutput = O

        required init() { }

        static func instance() -> Self { Self() }

        weak var _workflowPointer: AnyFlowRepresentable?
    }
}
