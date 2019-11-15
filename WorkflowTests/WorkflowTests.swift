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
            
            var proceedInWorkflow: ((Any?) -> Void)?
            
            static var shouldLoadCalledOnFR1 = false
            typealias IntakeType = String
            
            static func instance() -> AnyFlowRepresentable { FR1() }
            
            func shouldLoad(with args: String) -> Bool {
                FR1.shouldLoadCalledOnFR1 = true
                return true
            }
        }
        class FR2: FlowRepresentable {
            var preferredLaunchStyle: PresentationType = .default

            var presenter: AnyPresenter?
            
            var workflow: Workflow?
            
            var proceedInWorkflow: ((Any?) -> Void)?
            
            static var shouldLoadCalledOnFR2 = false
            typealias IntakeType = Int
            
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
    
    func testFlowRepresentablesThatDefineAnIntakeTypeOfOptionalAnyDoesNotRecurseForever() {
        class FR1: FlowRepresentable {
            var preferredLaunchStyle: PresentationType = .default

            var presenter: AnyPresenter?
            
            var workflow: Workflow?
            
            var proceedInWorkflow: ((Any?) -> Void)?
            
            static var shouldLoadCalledOnFR1 = false
            typealias IntakeType = Never
            
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
        (firstInstance?.value as? FR1)?.proceedInWorkflow()
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
        class FR1: TestFlowRepresentable<Never>, FlowRepresentable {
            static func instance() -> AnyFlowRepresentable { Self() }
        }
        class FR2: TestFlowRepresentable<Never>, FlowRepresentable {
            static func instance() -> AnyFlowRepresentable { Self() }
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
        class FR1: TestFlowRepresentable<Never>, FlowRepresentable {
            static func instance() -> AnyFlowRepresentable { FR1() }
        }
        XCTAssertThrowsFatalError{
            (presenter as AnyPresenter).launch(view: NotView(), from: NotView(), withLaunchStyle: .default, metadata: FlowRepresentableMetaData(FR1.self,
                                                                                                                              staysInViewStack: { _ in .default }), animated: false) { }
        }
    }
    
    class TestPresenter: AnyPresenter {
        var destroyCalled = 0
        func destroy(_ view: Any?) {
            destroyCalled += 1
        }
        
        var abandonCalled = 0
        func abandon(_ workflow: Workflow, animated:Bool = true, onFinish:(() -> Void)? = nil) {
            abandonCalled += 1
        }
        
        required init() { }
        
        var launchCalled = 0
        var launchView:Any?
        var launchRoot:Any?
        var launchStyle:PresentationType?
        func launch(view: Any?, from root: Any?, withLaunchStyle launchStyle: PresentationType, metadata: FlowRepresentableMetaData, animated:Bool, completion: (() -> Void)?) {
            launchCalled += 1
            launchView = view
            launchRoot = root
            self.launchStyle = launchStyle
        }
        
        var presentationType: PresentationType = .default
    }
    
    class TestTypedPresenter<T>: BasePresenter<T>, Presenter {
        func destroy(_ view: T) { }
        
        func launch(view: T, from root: T, withLaunchStyle launchStyle: PresentationType, metadata: FlowRepresentableMetaData, animated:Bool, completion:@escaping () -> Void) { }
        
        func abandon(_ workflow: Workflow, animated: Bool, onFinish: (() -> Void)?) { }
    }
    
    class TestFlowRepresentable<I> {
        required init() { }
        var preferredLaunchStyle: PresentationType = .default

        var proceedInWorkflow: ((Any?) -> Void)?
        
        typealias IntakeType = I
        
        var workflow: Workflow?
    }
}
