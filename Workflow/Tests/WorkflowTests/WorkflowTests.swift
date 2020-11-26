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
            var workflow: AnyWorkflow?
            
            var proceedInWorkflowStorage: ((Any?) -> Void)?
            
            static var shouldLoadCalledOnFR1 = false
            typealias WorkflowInput = String
            
            static func instance() -> AnyFlowRepresentable { FR1() }
            
            func shouldLoad(with args: String) -> Bool {
                FR1.shouldLoadCalledOnFR1 = true
                return true
            }
        }
        class FR2: FlowRepresentable {
            var workflow: AnyWorkflow?
            
            var proceedInWorkflowStorage: ((Any?) -> Void)?
            
            static var shouldLoadCalledOnFR2 = false
            typealias WorkflowInput = Int
            
            static func instance() -> AnyFlowRepresentable { FR2() }
            
            func shouldLoad(with args: Int) -> Bool {
                FR2.shouldLoadCalledOnFR2 = true
                return true
            }
        }
        let flow:[AnyFlowRepresentable.Type] = [FR1.self, FR2.self]
        var first = flow.first?.instance()
        var last = flow.last?.instance()
        _ = first?.erasedShouldLoad(with: "str")
        _ = last?.erasedShouldLoad(with: 1)
        
        XCTAssert(FR1.shouldLoadCalledOnFR1, "Should load not called on flow representable 1 with correct corresponding type")
        XCTAssert(FR2.shouldLoadCalledOnFR2, "Should load not called on flow representable 2 with correct corresponding type")
    }
    
    func testFlowRepresentablesThatDefineAWorkflowInputOfOptionalAnyDoesNotRecurseForever() {
        class FR1: FlowRepresentable {
            func shouldLoad(with args: Any?) -> Bool { true }
            
            var workflow: AnyWorkflow?
            
            var proceedInWorkflowStorage: ((Any?) -> Void)?
            
            static var shouldLoadCalledOnFR1 = false
            typealias WorkflowInput = Any?
            
            static func instance() -> AnyFlowRepresentable { FR1() }
        }
        
        var instance = FR1.instance() as? FR1
        XCTAssert(instance?.erasedShouldLoad(with: "str") == true)
    }

    func testProgressToNextAvailableItemInWorkflow() {
        class FR1: TestFlowRepresentable<Never>, FlowRepresentable {
            static func instance() -> AnyFlowRepresentable { Self() }
        }
        class FR2: TestFlowRepresentable<Never>, FlowRepresentable {
            static func instance() -> AnyFlowRepresentable { Self() }
            func shouldLoad() -> Bool { false }
        }
        class FR3: TestFlowRepresentable<Never>, FlowRepresentable {
            static func instance() -> AnyFlowRepresentable { Self() }
        }

        let responder = MockOrchestrationResponder()
        let wf = Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)

        wf.applyOrchestrationResponder(responder)

        let firstInstance = wf.launch(with: 1)
        XCTAssert(firstInstance?.value is FR1)
        XCTAssertNil(responder.lastFrom)
        XCTAssert(responder.lastTo?.instance.value is FR1)
        XCTAssert((responder.lastTo?.instance.value as? FR1) === firstInstance?.value as? FR1)
        XCTAssertEqual(responder.launchCalled, 1)
        (firstInstance?.value as? FR1)?.proceedInWorkflow()
        XCTAssertEqual(responder.proceedCalled, 1)
        XCTAssert((responder.lastFrom?.instance.value as? FR1) === firstInstance?.value as? FR1)
        XCTAssert(responder.lastTo?.instance.value is FR3)
        XCTAssert((responder.lastTo?.instance.value as? FR3) === firstInstance?.next?.next?.value as? FR3)
    }
    
    func testWorkflowReturnsNilWhenLaunchingWithoutRepresentables() {
        let wf:AnyWorkflow = AnyWorkflow()
        XCTAssertNil(wf.launch(with: nil))
    }

    func testWorkflowCallsBackOnCompletion() {
        class FR1: TestFlowRepresentable<Never>, FlowRepresentable {
            typealias WorkflowOutput = String
            static func instance() -> AnyFlowRepresentable { Self() }
        }
        class FR2: TestFlowRepresentable<Never>, FlowRepresentable {
            typealias WorkflowOutput = String
            static func instance() -> AnyFlowRepresentable { Self() }
        }

        let wf:Workflow = Workflow(FR1.self)
            .thenPresent(FR2.self)

        var callbackCalled = false
        let firstInstance = wf.launch(with: 1) { args in
            callbackCalled = true
            XCTAssertEqual(args as? String, "args")
        }
        XCTAssert(firstInstance?.value is FR1)
        (firstInstance?.value as? FR1)?.proceedInWorkflow("test")
        (firstInstance?.next?.value as? FR2)?.proceedInWorkflow("args")
        XCTAssert(callbackCalled)
    }

    func testWorkflowCallsBackOnCompletionWhenLastViewIsSkipped() {
        class FR1: TestFlowRepresentable<Never>, FlowRepresentable {
            typealias WorkflowOutput = String
            static func instance() -> AnyFlowRepresentable { Self() }
        }
        class FR2: TestFlowRepresentable<Never>, FlowRepresentable {
            typealias WorkflowOutput = String
            static func instance() -> AnyFlowRepresentable { Self() }

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
        XCTAssert(firstInstance?.value is FR1)
        (firstInstance?.value as? FR1)?.proceedInWorkflow("test")
        XCTAssert(callbackCalled)
    }

    func testWorkflowCallsBackOnCompletionWhenLastViewIsSkipped_AndItIsTheOnlyView() {
        class FR1: TestFlowRepresentable<Never>, FlowRepresentable {
            typealias WorkflowOutput = String
            static func instance() -> AnyFlowRepresentable { Self() }
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
    
    class TestFlowRepresentable<I> {
        required init() { }
        
        var proceedInWorkflowStorage: ((Any?) -> Void)?
        
        typealias WorkflowInput = I
        
        var workflow: AnyWorkflow?
    }
}
