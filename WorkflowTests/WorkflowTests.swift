//
//  WorkflowTests.swift
//  WorkflowTests
//
//  Created by Tyler Thompson on 8/25/19.
//  Copyright © 2019 Tyler Tompson. All rights reserved.
//

import XCTest
import UIUTest

@testable import Workflow
@testable import CwlPreconditionTesting

class WorkflowTests: XCTestCase {
    func testFlowRepresentablesWithMultipleTypesCanBeStoredInAnArray() {
        class FR1: FlowRepresentable {
            var preferredLaunchStyle: PresentationType = .default
            
            var presenter: AnyPresenter?
            
            var workflow: Workflow?
            
            var callback: ((Any?) -> Void)?
            
            static var shouldLoadCalledOnFR1 = false
            typealias IntakeType = String
            
            typealias OutputType = IntakeType
            
            static func instance() -> AnyFlowRepresentable {
                return FR1()
            }
            
            func shouldLoad(with args: String) -> Bool {
                FR1.shouldLoadCalledOnFR1 = true
                return true
            }
        }
        class FR2: FlowRepresentable {
            var preferredLaunchStyle: PresentationType = .default

            var presenter: AnyPresenter?
            
            var workflow: Workflow?
            
            var callback: ((Any?) -> Void)?
            
            static var shouldLoadCalledOnFR2 = false
            typealias IntakeType = Int
            
            typealias OutputType = Array<Int>
            
            static func instance() -> AnyFlowRepresentable {
                return FR2()
            }
            
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
    
    func testFlowRepresentablesThatDefineAnIntakeTypeOfOptionalAnyDoesNotRecurseForever() {
        class FR1: FlowRepresentable {
            var preferredLaunchStyle: PresentationType = .default

            func shouldLoad(with args: Any?) -> Bool { return true }
            
            var presenter: AnyPresenter?
            
            var workflow: Workflow?
            
            var callback: ((Any?) -> Void)?
            
            static var shouldLoadCalledOnFR1 = false
            typealias IntakeType = Any?
            
            static func instance() -> AnyFlowRepresentable {
                return FR1()
            }
        }

        XCTAssert((FR1.instance() as? FR1)?.shouldLoad(with: "str") == true)
    }
    
    func testProgressToNextAvailableItemInWorkflow() {
        class FR1: TestFlowRepresentable<Int>, FlowRepresentable {
            static func instance() -> AnyFlowRepresentable {
                return FR1()
            }
            
            func shouldLoad(with args: Int) -> Bool {
                return true
            }
        }
        class FR2: TestFlowRepresentable<String>, FlowRepresentable {
            static func instance() -> AnyFlowRepresentable {
                return FR2()
            }
            
            func shouldLoad(with args: String) -> Bool {
                return false
            }
        }
        class FR3: TestFlowRepresentable<String>, FlowRepresentable {
            func shouldLoad(with args: String) -> Bool {
                return true
            }
            
            static func instance() -> AnyFlowRepresentable {
                return FR3()
            }
        }
        class TestView { }
        
        let presenter = TestPresenter()
        let wf:Workflow = [FR1.self, FR2.self, FR3.self]
        wf.applyPresenter(presenter)
        
        let view = TestView()
        let firstInstance = wf.launch(from: view, with: 1)
        XCTAssert(firstInstance?.value is FR1)
        XCTAssert(presenter.launchRoot is TestView)
        XCTAssert((presenter.launchRoot as? TestView) === view)
        XCTAssert(presenter.launchView is FR1)
        XCTAssert((presenter.launchView as? FR1) === firstInstance?.value as? FR1)
        XCTAssertEqual(presenter.launchCalled, 1)
        (firstInstance?.value as? FR1)?.proceedInWorkflow("test")
        XCTAssertEqual(presenter.launchCalled, 2)
        XCTAssert((presenter.launchRoot as? FR1) === firstInstance?.value as? FR1)
        XCTAssert(presenter.launchView is FR3)
        XCTAssert((presenter.launchView as? FR3) === firstInstance?.next?.next?.value as? FR3)
    }
    
    func testWorkflowReturnsNilWhenLaunchingWithoutRepresentables() {
        let wf:Workflow = []
        XCTAssertNil(wf.launch(from: nil, with: nil))
    }
    
    func testWorkflowCallsBackOnCompletion() {
        class FR1: TestFlowRepresentable<Int>, FlowRepresentable {
            static func instance() -> AnyFlowRepresentable {
                return FR1()
            }
            
            func shouldLoad(with args: Int) -> Bool {
                return true
            }
        }
        class FR2: TestFlowRepresentable<String>, FlowRepresentable {
            func shouldLoad(with args: String) -> Bool {
                return true
            }
            
            static func instance() -> AnyFlowRepresentable {
                return FR2()
            }
        }
        class TestView { }
        
        let wf:Workflow = [FR1.self, FR2.self]
        
        let view = TestView()
        var callbackCalled = false
        let firstInstance = wf.launch(from: view, with: 1) { args in
            callbackCalled = true
            XCTAssertEqual(args as? String, "args")
        }
        XCTAssert(firstInstance?.value is FR1)
        (firstInstance?.value as? FR1)?.proceedInWorkflow("test")
        (firstInstance?.next?.value as? FR2)?.proceedInWorkflow("args")
        XCTAssert(callbackCalled)
    }
    
    func testPresenterThrowsAFatalErrorWhenThereIsATypeMismatch() {
        class View { }
        class NotView { }
        let presenter = TestTypedPresenter<View>()
        XCTAssertThrowsFatalError{
            presenter.launch(view: NotView(), from: NotView(), withLaunchStyle: .default)
        }
    }
    
    class TestPresenter: AnyPresenter {
        var abandonCalled = 0
        func abandon(_ workflow: Workflow, animated:Bool = true, onFinish:(() -> Void)? = nil) {
            abandonCalled += 1
        }
        
        required init() { }
        
        var launchCalled = 0
        var launchView:Any?
        var launchRoot:Any?
        var launchStyle:PresentationType?
        func launch(view: Any?, from root: Any?, withLaunchStyle launchStyle: PresentationType) {
            launchCalled += 1
            launchView = view
            launchRoot = root
            self.launchStyle = launchStyle
        }
        
        var presentationType: PresentationType = .default
    }
    
    class TestTypedPresenter<T>: BasePresenter<T>, Presenter {
        func launch(view: T, from root: T, withLaunchStyle launchStyle: PresentationType) { }
        
        func abandon(_ workflow: Workflow, animated: Bool, onFinish: (() -> Void)?) { }
    }
    
    class TestFlowRepresentable<I> {
        var preferredLaunchStyle: PresentationType = .default

        var callback: ((Any?) -> Void)?
        
        typealias IntakeType = I
        
        var workflow: Workflow?
    }
}
