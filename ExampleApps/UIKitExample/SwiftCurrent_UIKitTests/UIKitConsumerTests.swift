//
//  UIKitConsumerTests.swift
//  WorkflowTests
//
//  Created by Tyler Thompson on 8/26/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
import UIUTest

// Do *not* change to @testable import, we want tests driven from the consumer standpoint
import SwiftCurrent
import SwiftCurrent_UIKit

class UIKitConsumerTests: XCTestCase {
    static var viewDidLoadOnMockCalled = 0

    override func setUpWithError() throws {
        Self.viewDidLoadOnMockCalled = 0
        UIView.setAnimationsEnabled(false)
        UIViewController.initializeTestable()
    }

    override func tearDownWithError() throws {
        UIViewController.flushPendingTestArtifacts()
        UIView.setAnimationsEnabled(true)
    }

    func testCreateViewControllerWithBaseClassForEase() {
        class FR1: UIWorkflowItem<Int, Never>, FlowRepresentable {
            static var shouldLoadCalled = false
            required init(with args: Int) {
                super.init(nibName: nil, bundle: nil)
                view.backgroundColor = .green
            }
            required init?(coder: NSCoder) { nil }

            func shouldLoad() -> Bool {
                FR1.shouldLoadCalled = true
                return true
            }
        }

        let root = UIViewController()
        root.view.backgroundColor = .blue
        root.loadForTesting()

        let wf = Workflow(FR1.self)

        root.launchInto(wf, args: 20000)

        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)

        XCTAssert(FR1.shouldLoadCalled)
    }

    func testFlowCanBeFullyFollowed() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        class FR4: TestViewController { }

        let root = UIViewController()
        let nav = UINavigationController(rootViewController: root)
        nav.loadForTesting()

        root.launchInto(Workflow(FR1.self)
                            .thenPresent(FR2.self)
                            .thenPresent(FR3.self)
                            .thenPresent(FR4.self))

        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController() as? FR3)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR4.self)
    }

    func testFinishingWorkflowCallsBack() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        class FR4: TestViewController { }

        let root = UIViewController()
        let nav = UINavigationController(rootViewController: root)
        nav.loadForTesting()
        class Obj { }
        let obj = Obj()

        var callbackCalled = false
        root.launchInto(Workflow(FR1.self)
                            .thenPresent(FR2.self)
                            .thenPresent(FR3.self)
                            .thenPresent(FR4.self), args: obj) { args in
            callbackCalled = true
            XCTAssert(args.extractArgs(defaultValue: nil) as? Obj === obj)
        }

        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.next()
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.next()
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController() as? FR3)?.next()
        XCTAssertUIViewControllerDisplayed(ofType: FR4.self)
        (UIApplication.topViewController() as? FR4)?.next()
        XCTAssert(callbackCalled)
    }

    func testViewDidLoadGetsCalledWhereAppropriate() {
        UIKitConsumerTests.viewDidLoadOnMockCalled = 0
        final class MockFlowRepresentable: UIWorkflowItem<Never, Never>, FlowRepresentable {
            // The protocol synthesizes a shouldLoad function that returns true. The super class (this) is considered to have it by Swift.  When you inherit and declare it again, Swift considers the subclass to not have overwritten but instead declared a new function.  By declaring here we say that we don't care about the synthesized function and our subclass can then override.  This only matters if your superclass is a FlowRepresentable.
            func shouldLoad() -> Bool { true }

            override func viewDidLoad() {
                UIKitConsumerTests.viewDidLoadOnMockCalled += 1
            }
        }

        class FR1: TestViewController { }
        final class FR2: UIWorkflowItem<Never, Never>, FlowRepresentable { }

        let root = UIViewController()
        let nav = UINavigationController(rootViewController: root)
        nav.loadForTesting()

        root.launchInto(Workflow(FR1.self)
                            .thenPresent(MockFlowRepresentable.self)
                            .thenPresent(FR2.self))

        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)

        // Go forward to mock
        (UIApplication.topViewController() as? FR1)?.next()
        XCTAssertUIViewControllerDisplayed(ofType: MockFlowRepresentable.self)
        XCTAssertEqual(UIKitConsumerTests.viewDidLoadOnMockCalled, 1)

        // Go to Final
        (UIApplication.topViewController() as? MockFlowRepresentable)?.proceedInWorkflow()
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        UIApplication.topViewController()?.navigationController?.popViewController(animated: false)

        // Go back to Mock
        XCTAssertUIViewControllerDisplayed(ofType: MockFlowRepresentable.self)
        XCTAssertEqual(UIKitConsumerTests.viewDidLoadOnMockCalled, 1)

        // Go back to First
        UIApplication.topViewController()?.navigationController?.popViewController(animated: false)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)

        // Go forward to Mock
        (UIApplication.topViewController() as? FR1)?.next()

        XCTAssertUIViewControllerDisplayed(ofType: MockFlowRepresentable.self)
        XCTAssertEqual(UIKitConsumerTests.viewDidLoadOnMockCalled, 2)
    }

    func testFlowRepresentableThatDoesNotTakeInData() {
        class ExpectedController: UIWorkflowItem<Never, Never>, FlowRepresentable {
            required init() {
                super.init(nibName: nil, bundle: nil)
                view.backgroundColor = .green
            }

            required init?(coder: NSCoder) { nil }
        }

        let rootController = UIViewController()
        rootController.loadForTesting()

        rootController.launchInto(Workflow(ExpectedController.self), withLaunchStyle: .navigationStack)
        RunLoop.current.singlePass()

        XCTAssert(rootController.mostRecentlyPresentedViewController is UINavigationController, "mostRecentlyPresentedViewController should be nav controller: \(String(describing: rootController.mostRecentlyPresentedViewController))")
        XCTAssertEqual((rootController.mostRecentlyPresentedViewController as? UINavigationController)?.viewControllers.count, 1)
        XCTAssert((rootController.mostRecentlyPresentedViewController as? UINavigationController)?.viewControllers.first is ExpectedController)
    }

    func testFlowRepresentableThatDoesNotTakeInDataAndOverridesShouldLoad() {
        class ExpectedController: UIWorkflowItem<Never, Never>, FlowRepresentable {
            required init() {
                super.init(nibName: nil, bundle: nil)
                view.backgroundColor = .green
            }

            required init?(coder: NSCoder) { nil }
            func shouldLoad() -> Bool { false }
        }

        let rootController = UIViewController()
        rootController.loadForTesting()

        rootController.launchInto(Workflow(ExpectedController.self))

        RunLoop.current.singlePass()

        XCTAssert(UIApplication.topViewController() === rootController)
    }

    func testInstantiatingWorkflow_WithFlowPersistenceClosure() {
        let expectation = self.expectation(description: "Flow Persistence Closure Called")
        let expectedArgs = UUID().uuidString
        class FR1: UIWorkflowItem<String, Never>, FlowRepresentable {
            required init(with args: String) {
                super.init(nibName: nil, bundle: nil)
            }
            required init?(coder: NSCoder) { fatalError() }
        }

        let wf = Workflow(FR1.self, presentationType: .modal) { args in
            expectation.fulfill()
            XCTAssertEqual(args, expectedArgs)
            return .persistWhenSkipped
        }

        let root = UIViewController()
        root.loadForTesting()

        root.launchInto(wf, args: expectedArgs)

        wait(for: [expectation], timeout: 0.5)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testInstantiatingWorkflow_WithFlowPersistenceAutoClosure_AndAnInputOfNever() {
        let expectedArgs = UUID().uuidString
        class FR1: UIWorkflowItem<Never, Never>, FlowRepresentable { }

        let wf = Workflow(FR1.self, presentationType: .modal, flowPersistence: .persistWhenSkipped)

        let root = UIViewController()
        root.loadForTesting()

        root.launchInto(wf, args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testInstantiatingWorkflow_WithFlowPersistenceAutoClosure_AndAnInputOfPassedArgs() {
        let expectedArgs = UUID().uuidString
        class FR1: UIWorkflowItem<AnyWorkflow.PassedArgs, Never>, FlowRepresentable {
            required init(with args: AnyWorkflow.PassedArgs) {
                super.init(nibName: nil, bundle: nil)
            }
            required init?(coder: NSCoder) { fatalError() }
        }

        let wf = Workflow(FR1.self, presentationType: .modal, flowPersistence: .persistWhenSkipped)

        let root = UIViewController()
        root.loadForTesting()

        root.launchInto(wf, args: expectedArgs)

        XCTAssertEqual(wf.first?.value.metadata.persistence, .persistWhenSkipped)
    }

    func testProceedingInWorkflow_WithFlowPersistenceAutoClosure_AndAnInputOfPassedArgs() {
        let expectedArgs = UUID().uuidString
        class FR1: UIWorkflowItem<Never, Never>, FlowRepresentable { }
        class FR2: UIWorkflowItem<AnyWorkflow.PassedArgs, Never>, FlowRepresentable {
            required init(with args: AnyWorkflow.PassedArgs) {
                super.init(nibName: nil, bundle: nil)
            }
            required init?(coder: NSCoder) { fatalError() }
        }

        let wf = Workflow(FR1.self)
            .thenPresent(FR2.self, presentationType: .modal, flowPersistence: .persistWhenSkipped)

        let root = UIViewController()
        root.loadForTesting()

        root.launchInto(wf, args: expectedArgs)

        (wf.first?.value.instance?.underlyingInstance as? FR1)?.proceedInWorkflow()

        XCTAssertEqual(wf.first?.next?.value.metadata.persistence, .persistWhenSkipped)
    }

}

extension UIKitConsumerTests {
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
