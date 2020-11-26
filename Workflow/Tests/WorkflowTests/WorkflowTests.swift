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
    func testFlowRepresentablesWithMultipleTypesCanBeStoredIAndRetreived() {
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

    #warning("FINDME")
//    func testProgressToNextAvailableItemInWorkflow() {
//        class FR1: TestFlowRepresentable<Never>, FlowRepresentable {
//            static func instance() -> AnyFlowRepresentable { Self() }
//        }
//        class FR2: TestFlowRepresentable<Never>, FlowRepresentable {
//            static func instance() -> AnyFlowRepresentable { Self() }
//            func shouldLoad() -> Bool { false }
//        }
//        class FR3: TestFlowRepresentable<Never>, FlowRepresentable {
//            static func instance() -> AnyFlowRepresentable { Self() }
//        }
//        class TestView { }
//
//        let presenter = TestPresenter()
//        let wf = Workflow(FR1.self)
//            .thenPresent(FR2.self)
//            .thenPresent(FR3.self)
//
//        wf.applyPresenter(presenter)
//
//        let view = TestView()
//        let firstInstance = wf.launch(from: view, with: 1)
//        XCTAssert(firstInstance?.value is FR1)
//        XCTAssert(presenter.launchRoot is TestView)
//        XCTAssert((presenter.launchRoot as? TestView) === view)
//        XCTAssert(presenter.launchView is FR1)
//        XCTAssert((presenter.launchView as? FR1) === firstInstance?.value as? FR1)
//        XCTAssertEqual(presenter.launchCalled, 1)
//        (firstInstance?.value as? FR1)?.proceedInWorkflow()
//        XCTAssertEqual(presenter.launchCalled, 2)
//        XCTAssert((presenter.launchRoot as? FR1) === firstInstance?.value as? FR1)
//        XCTAssert(presenter.launchView is FR3)
//        XCTAssert((presenter.launchView as? FR3) === firstInstance?.next?.next?.value as? FR3)
//    }
    
    func testWorkflowReturnsNilWhenLaunchingWithoutRepresentables() {
        let wf:AnyWorkflow = AnyWorkflow()
        XCTAssertNil(wf.launch(from: nil, with: nil))
    }

    #warning("FINDME")
//    func testWorkflowCallsBackOnCompletion() {
//        class FR1: TestFlowRepresentable<Never>, FlowRepresentable {
//            typealias WorkflowOutput = String
//            static func instance() -> AnyFlowRepresentable { Self() }
//        }
//        class FR2: TestFlowRepresentable<Never>, FlowRepresentable {
//            typealias WorkflowOutput = String
//            static func instance() -> AnyFlowRepresentable { Self() }
//        }
//        class TestView { }
//
//        let wf:Workflow = Workflow(FR1.self)
//            .thenPresent(FR2.self)
//
//        let view = TestView()
//        var callbackCalled = false
//        let firstInstance = wf.launch(from: view, with: 1) { args in
//            callbackCalled = true
//            XCTAssertEqual(args as? String, "args")
//        }
//        XCTAssert(firstInstance?.value is FR1)
//        (firstInstance?.value as? FR1)?.proceedInWorkflow("test")
//        (firstInstance?.next?.value as? FR2)?.proceedInWorkflow("args")
//        XCTAssert(callbackCalled)
//    }

    #warning("FINDME")
//    func testWorkflowCallsBackOnCompletionWhenLastViewIsSkipped() {
//        class FR1: TestFlowRepresentable<Never>, FlowRepresentable {
//            typealias WorkflowOutput = String
//            static func instance() -> AnyFlowRepresentable { Self() }
//        }
//        class FR2: TestFlowRepresentable<Never>, FlowRepresentable {
//            typealias WorkflowOutput = String
//            static func instance() -> AnyFlowRepresentable { Self() }
//
//            func shouldLoad() -> Bool {
//                proceedInWorkflow("args")
//                return false
//            }
//        }
//        class TestView { }
//
//        let wf:Workflow = Workflow(FR1.self)
//            .thenPresent(FR2.self)
//
//        let view = TestView()
//        var callbackCalled = false
//        let firstInstance = wf.launch(from: view, with: 1) { args in
//            callbackCalled = true
//            XCTAssertEqual(args as? String, "args")
//        }
//        XCTAssert(firstInstance?.value is FR1)
//        (firstInstance?.value as? FR1)?.proceedInWorkflow("test")
//        XCTAssert(callbackCalled)
//    }

    #warning("FINDME")
//    func testWorkflowCallsBackOnCompletionWhenLastViewIsSkipped_AndItIsTheOnlyView() {
//        class FR1: TestFlowRepresentable<Never>, FlowRepresentable {
//            typealias WorkflowOutput = String
//            static func instance() -> AnyFlowRepresentable { Self() }
//            func shouldLoad() -> Bool {
//                proceedInWorkflow("args")
//                return false
//            }
//        }
//        class TestView { }
//
//        let wf:Workflow = Workflow(FR1.self)
//
//        let view = TestView()
//        var callbackCalled = false
//        _ = wf.launch(from: view, with: 1) { args in
//            callbackCalled = true
//            XCTAssertEqual(args as? String, "args")
//        }
//        XCTAssert(callbackCalled)
//    }
    
    class TestFlowRepresentable<I> {
        required init() { }
        
        var proceedInWorkflowStorage: ((Any?) -> Void)?
        
        typealias WorkflowInput = I
        
        var workflow: AnyWorkflow?
    }
}
