//
//  UIKitConsumerAbandonTests.swift
//  WorkflowUIKitTests
//
//  Created by Richard Gist on 5/12/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
import UIUTest

// Do *not* change to @testable import, we want tests driven from the consumer standpoint
import SwiftCurrent
import SwiftCurrent_UIKit

class UIKitConsumerAbandonTests: XCTestCase {
    static var testCallbackCalled = false
    let testCallback = {
        UIKitConsumerAbandonTests.testCallbackCalled = true
    }

    override func setUpWithError() throws {
        Self.testCallbackCalled = false
        UIView.setAnimationsEnabled(false)
        UIViewController.initializeTestable()
    }

    override func tearDownWithError() throws {
        UIViewController.flushPendingTestArtifacts()
        UIView.setAnimationsEnabled(true)
    }

    func testAbandonWorkflowWithoutNavigationController() {
        class FR1: UIViewController, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        let root = UIViewController()
        root.view.backgroundColor = .blue
        root.loadForTesting()

        let wf = Workflow(FR1.self)

        root.launchInto(wf)

        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)

        (UIApplication.topViewController() as? FR1)?.abandonWorkflow()

        waitUntil(!(UIApplication.topViewController() is FR1))

        XCTAssert(UIApplication.topViewController() === root)
    }

    func testAbandonWorkflowCallsOnFinishCallback() {
        class FR1: UIViewController, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        let expectation = self.expectation(description: "Abandon callback called")
        let root = UIViewController()
        root.view.backgroundColor = .blue
        root.loadForTesting()

        let wf = Workflow(FR1.self)
        root.launchInto(wf)

        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)

        (UIApplication.topViewController() as? FR1)?.abandonWorkflow {
            expectation.fulfill()
        }

        waitUntil(!(UIApplication.topViewController() is FR1))

        XCTAssert(UIApplication.topViewController() === root)
        wait(for: [expectation], timeout: 0.1)
    }

    func testAbandonWorkflowWithNavigationController() {
        class FR1: UIViewController, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        let root = UIViewController()
        root.view.backgroundColor = .blue
        let nav = UINavigationController(rootViewController: root)
        nav.loadForTesting()

        let wf = Workflow(FR1.self)

        root.launchInto(wf)

        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)

        (UIApplication.topViewController() as? FR1)?.abandonWorkflow()

        waitUntil(!(UIApplication.topViewController() is FR1))

        XCTAssert(UIApplication.topViewController() === root)
    }

    func testAbandonWorkflowWithNavigationControllerWhichHasSomeViewControllersAlready() {
        class FR1: UIViewController, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        let root = UIViewController()
        root.view.backgroundColor = .blue
        let second = UIViewController()
        root.view.backgroundColor = .red
        let nav = UINavigationController(rootViewController: root)
        nav.pushViewController(second, animated: false)
        nav.loadForTesting()

        let wf = Workflow(FR1.self)

        root.launchInto(wf)

        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)

        (UIApplication.topViewController() as? FR1)?.abandonWorkflow()

        waitUntil(!(UIApplication.topViewController() is FR1))

        XCTAssert(UIApplication.topViewController() === second)
    }

    func testWorkflowAbandonWhenNavControllerOnlyHasOneViewController() {
        let rootController = UIViewController()
        let controller = UINavigationController(rootViewController: rootController)
        controller.loadForTesting()

        let workflow = Workflow(TestViewController.self)

        rootController.launchInto(workflow)

        XCTAssertUIViewControllerDisplayed(ofType: TestViewController.self)

        workflow.abandon(animated: false, onFinish: testCallback)

        XCTAssertUIViewControllerDisplayed(isInstance: rootController)
        XCTAssertTrue(Self.testCallbackCalled)
    }

    func testWorkflowAbandonWhenLaunchedFromNavController_ExpectVCsToBeEmpty() {
        let controller = UINavigationController()
        controller.loadForTesting()

        let workflow = Workflow(TestViewController.self)

        controller.launchInto(workflow)

        XCTAssertUIViewControllerDisplayed(ofType: TestViewController.self)

        workflow.abandon(animated: false, onFinish: testCallback)

        waitUntil(UIApplication.topViewController() === controller)
        XCTAssert(controller.viewControllers.isEmpty)
        XCTAssertTrue(Self.testCallbackCalled)
    }

    func testWorkflowAbandonWhenNoNavigationControllerExists() {
        let rootController = UIViewController()
        rootController.loadForTesting()

        let workflow = Workflow(TestViewController.self)

        rootController.launchInto(workflow)

        XCTAssertUIViewControllerDisplayed(ofType: TestViewController.self)

        workflow.abandon(animated: false, onFinish: testCallback)

        XCTAssertUIViewControllerDisplayed(isInstance: rootController)
        XCTAssertTrue(Self.testCallbackCalled)
    }

    func testWorkflowAbandonWhenLaunchStyleIsNavigationStack() {
        let rootController = UIViewController()
        rootController.loadForTesting()

        let workflow = Workflow(TestViewController.self)

        rootController.launchInto(workflow, withLaunchStyle: .navigationStack)

        XCTAssertUIViewControllerDisplayed(ofType: TestViewController.self)

        workflow.abandon(animated: false, onFinish: testCallback)

        XCTAssertUIViewControllerDisplayed(isInstance: rootController)
        XCTAssertTrue(Self.testCallbackCalled)
    }

    func testAbandonWhenWorkflowHasNavPresentingSubsequentViewsModally() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        class FR4: TestViewController { }

        let root = UIViewController()
        root.loadForTesting()

        root.launchInto(Workflow(FR1.self)
                            .thenProceed(with: FR2.self, launchStyle: .modal)
                            .thenProceed(with: FR3.self)
                            .thenProceed(with: FR4.self), withLaunchStyle: .navigationStack)

        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        XCTAssertNotNil(UIApplication.topViewController()?.navigationController)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        XCTAssertNil(UIApplication.topViewController()?.navigationController)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController() as? FR3)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR4.self)
        (UIApplication.topViewController() as? FR4)?.abandonWorkflow()
        XCTAssertUIViewControllerDisplayed(isInstance: root)
    }
    
    func testAbandonCalledOnFlowRepresentableWhenWorkflowHasNoNavPresentingSubsequentViewsModally() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        class FR4: TestViewController { }

        let root = UIViewController()
        root.loadForTesting()

        root.launchInto(Workflow(FR1.self)
                            .thenProceed(with: FR2.self)
                            .thenProceed(with: FR3.self)
                            .thenProceed(with: FR4.self), withLaunchStyle: .modal)

        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController() as? FR3)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR4.self)
        (UIApplication.topViewController() as? FR4)?.abandonWorkflow()
        XCTAssertUIViewControllerDisplayed(isInstance: root)
    }
    
    func testAbandonCalledOnWorkflowWhenWorkflowHasNoNavPresentingSubsequentViewsModally() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        class FR4: TestViewController { }

        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self)
            .thenProceed(with: FR4.self)
        
        let root = UIViewController()
        root.loadForTesting()
        
        root.launchInto(wf, withLaunchStyle: .modal) { _ in
            wf.abandon()
        }
        
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController() as? FR3)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR4.self)
        (UIApplication.topViewController() as? FR4)?.proceedInWorkflow(nil)

        XCTAssertUIViewControllerDisplayed(isInstance: root)
    }
    
    func testLaunchingViewControllerIsNotDismissedWhenWorkflowAbandons() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        class FR4: TestViewController { }

        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self)
            .thenProceed(with: FR3.self)
            .thenProceed(with: FR4.self)
        
        let root = UIViewController()
        root.loadForTesting()
        let vc = UIViewController()
        root.present(vc, animated: false)
        
        vc.launchInto(wf, withLaunchStyle: .modal) { _ in
            wf.abandon()
        }
        
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController() as? FR3)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR4.self)
        (UIApplication.topViewController() as? FR4)?.proceedInWorkflow(nil)

        XCTAssertUIViewControllerDisplayed(isInstance: vc)
    }

    func testLaunchingViewControllerIsNotDismissedWhenFlowRepresentableAbandons() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        class FR4: TestViewController { }

        let wf = Workflow(FR1.self)
            .thenProceed(with: FR2.self, launchStyle: .modal)
            .thenProceed(with: FR3.self, launchStyle: .modal)
            .thenProceed(with: FR4.self, launchStyle: .modal)
        
        let root = UIViewController()
        root.loadForTesting()
        let vc = UIViewController()
        root.present(vc, animated: false)
        
        let presenter = UIKitPresenter(vc, launchStyle: .modal)
        
        wf.launch(withOrchestrationResponder: presenter)
        
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController() as? FR3)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR4.self)
        (UIApplication.topViewController() as? FR4)?.abandonWorkflow()

        XCTAssertUIViewControllerDisplayed(isInstance: vc)
    }
    
    func testAbandonWhenFluentWorkflowHasNavPresentingSubsequentViewsModally() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        class FR4: TestViewController { }

        let root = UIViewController()
        root.loadForTesting()
        root.launchInto(
            Workflow(FR1.self)
                .thenProceed(with: FR2.self, launchStyle: .modal)
                .thenProceed(with: FR3.self)
                .thenProceed(with: FR4.self),
            withLaunchStyle: .navigationStack)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        XCTAssertNotNil(UIApplication.topViewController()?.navigationController)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        XCTAssertNil(UIApplication.topViewController()?.navigationController)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController() as? FR3)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR4.self)
        (UIApplication.topViewController() as? FR4)?.abandonWorkflow()
        XCTAssertUIViewControllerDisplayed(isInstance: root)
    }

    func testAbandonWhenWorkflowHasNavPresentingSubsequentViewsModallyAndWithMoreNavigation() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        class FR4: TestViewController { }

        let root = UIViewController()
        root.loadForTesting()
        root.launchInto(Workflow(FR1.self)
                            .thenProceed(with: FR2.self, launchStyle: .modal)
                            .thenProceed(with: FR3.self, launchStyle: .navigationStack)
                            .thenProceed(with: FR4.self, launchStyle: .modal),
                        withLaunchStyle: .navigationStack)

        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        XCTAssertNotNil(UIApplication.topViewController()?.navigationController)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        XCTAssertNil(UIApplication.topViewController()?.navigationController)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController() as? FR3)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR4.self)
        (UIApplication.topViewController() as? FR4)?.abandonWorkflow()
        XCTAssertUIViewControllerDisplayed(isInstance: root)
    }

    func testAbandonWhenFluentWorkflowHasNavPresentingSubsequentViewsModallyAndWithMoreNavigation() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        class FR4: TestViewController { }

        let root = UIViewController()
        root.loadForTesting()
        root.launchInto(
            Workflow(FR1.self)
                .thenProceed(with: FR2.self, launchStyle: .modal)
                .thenProceed(with: FR3.self, launchStyle: .navigationStack)
                .thenProceed(with: FR4.self, launchStyle: .modal),
            withLaunchStyle: .navigationStack)

        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        XCTAssertNotNil(UIApplication.topViewController()?.navigationController)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        XCTAssertNil(UIApplication.topViewController()?.navigationController)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController() as? FR3)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR4.self)
        (UIApplication.topViewController() as? FR4)?.abandonWorkflow()
        XCTAssertUIViewControllerDisplayed(isInstance: root)
    }

    func testAbandonWhenWorkflowHasNavWithStartingViewPresentingSubsequentViewsModallyAndWithMoreNavigation() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        class FR4: TestViewController { }

        let root = UIViewController()
        let nav = UINavigationController(rootViewController: root)
        nav.loadForTesting()

        root.launchInto(Workflow(FR1.self)
                            .thenProceed(with: FR2.self, launchStyle: .modal)
                            .thenProceed(with: FR3.self, launchStyle: .navigationStack)
                            .thenProceed(with: FR4.self, launchStyle: .modal),
                        withLaunchStyle: .navigationStack)

        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        XCTAssertNotNil(UIApplication.topViewController()?.navigationController)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        XCTAssertNil(UIApplication.topViewController()?.navigationController)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController() as? FR3)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR4.self)
        (UIApplication.topViewController() as? FR4)?.abandonWorkflow()
        XCTAssertUIViewControllerDisplayed(isInstance: root)
    }

    func testUIKitPresenterRespondsToAbandonActionCorrectly() {
        class FR1: UIWorkflowItem<Never, Never>, FlowRepresentable { }

        let expectation = self.expectation(description: "Abandon Called")
        let root = UIViewController()
        root.loadForTesting()

        let wf = Workflow(FR1.self)
        root.launchInto(wf)

        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)

        wf.orchestrationResponder?.abandon(AnyWorkflow(wf)) {
            expectation.fulfill()
        }

        XCTAssertUIViewControllerDisplayed(isInstance: root)

        wait(for: [expectation], timeout: 0.5)
    }

    func testUIKitAbandon_CanStillAbandon_EvenIfTheResponderIsNotAUIKitPresenter() {
        class FR1: UIWorkflowItem<Never, Never>, FlowRepresentable { }

        let expectation = self.expectation(description: "Abandon Called")
        let root = UIViewController()
        root.loadForTesting()

        let wf = Workflow(FR1.self)
        let responder = MockOrchestrationResponder()
        wf.launch(withOrchestrationResponder: responder)

        XCTAssertNotNil(wf.first?.value.instance)

        wf.abandon(animated: false) {
            expectation.fulfill()
        }

        responder.lastOnFinish?()

        wait(for: [expectation], timeout: 0.1)

        XCTAssertNil((wf.first?.value.instance?.underlyingInstance as? FR1)?.proceedInWorkflowStorage)
        XCTAssertNil(wf.first?.value.instance)
    }

}

extension UIKitConsumerAbandonTests {
    class TestViewController: UIWorkflowItem<AnyWorkflow.PassedArgs, Any?>, FlowRepresentable {
        var data: Any?
        required init(with args: AnyWorkflow.PassedArgs) {
            super.init(nibName: nil, bundle: nil)
            view.backgroundColor = .red
            data = args.extractArgs(defaultValue: nil)
        }

        required init?(coder: NSCoder) { nil }

        // See important documentation on FlowRepresentable
        func shouldLoad() -> Bool { true }

        func next() {
            proceedInWorkflow(data)
        }
    }
}
