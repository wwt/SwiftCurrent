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
import Workflow
import WorkflowUIKit

class UIKitConsumerTests: XCTestCase {
    static var testCallbackCalled = false
    let testCallback = {
        UIKitConsumerTests.testCallbackCalled = true
    }

    override func setUpWithError() throws {
        UIKitConsumerTests.testCallbackCalled = false
        UIKitConsumerTests.viewDidLoadOnMockCalled = 0
        UIView.setAnimationsEnabled(false)
        UIViewController.initializeTestable()
    }

    override func tearDownWithError() throws {
        UIViewController.flushPendingTestArtifacts()
        UIView.setAnimationsEnabled(true)
    }

    func testWorkflowCanLaunchViewController() {
        class FR1: UIViewController, FlowRepresentable {
            typealias WorkflowInput = Never

            weak var _workflowPointer: AnyFlowRepresentable?
        }
        let flow = Workflow(FR1.self)

        let root = UIViewController()
        root.loadForTesting()
        root.launchInto(flow)

        XCTAssert(UIApplication.topViewController() is FR1)
    }

    func testWorkflowCanSkipTheFirstView() {
        final class FR1: UIViewController, FlowRepresentable {
            typealias WorkflowInput = String?
            typealias WorkflowOutput = Int?

            weak var _workflowPointer: AnyFlowRepresentable?

            init(with args: String?) { super.init(nibName: nil, bundle: nil) }
            required init?(coder: NSCoder) { nil }

            func shouldLoad() -> Bool {
                proceedInWorkflow(1)
                return false
            }
        }
        class FR2: UIViewController, FlowRepresentable {
            typealias WorkflowInput = Int?

            weak var _workflowPointer: AnyFlowRepresentable?

            required init(with args: Int?) { super.init(nibName: nil, bundle: nil) }
            required init?(coder: NSCoder) { nil }
        }
        let flow = Workflow(FR1.self)
            .thenPresent(FR2.self)

        let root = UIViewController()
        UIApplication.shared.windows.first?.rootViewController = root

        root.launchInto(flow, args: "")

        XCTAssert(UIApplication.topViewController() is FR2)
    }

    func testWorkflowCanPushOntoExistingNavController() {
        class FR1: UIViewController, FlowRepresentable {
            typealias WorkflowInput = Never

            weak var _workflowPointer: AnyFlowRepresentable?
        }
        let root = UIViewController()
        root.view.backgroundColor = .blue
        let nav = UINavigationController(rootViewController: root)
        nav.loadForTesting()

        root.launchInto(Workflow(FR1.self))

        XCTAssert(UIApplication.topViewController() is FR1)
        XCTAssert(nav.visibleViewController is FR1)
        XCTAssert(nav.viewControllers.last is FR1)
    }

    func testAbandonWorkflowWithoutNavigationController() {
        class FR1: UIViewController, FlowRepresentable {
            typealias WorkflowInput = Never

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

    func testAbandonWorkflowWithNavigationController() {
        class FR1: UIViewController, FlowRepresentable {
            typealias WorkflowInput = Never

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
            typealias WorkflowInput = Never

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

    func testLaunchWorkflowWithArguments() {
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

        root.launchInto(wf, args: 1)

        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)

        XCTAssert(FR1.shouldLoadCalled)
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

    func testFlowPresentsOnNavStackWhenNavHasNoRoot() {
        class FR1: TestViewController { }

        let nav = UINavigationController()
        nav.loadForTesting()

        nav.launchInto(Workflow(FR1.self))
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        XCTAssertNil(nav.mostRecentlyPresentedViewController)
        XCTAssertNotNil(UIApplication.topViewController()?.navigationController)
        XCTAssertEqual(UIApplication.topViewController()?.navigationController?.viewControllers.count, 1)
        XCTAssert(UIApplication.topViewController()?.navigationController?.visibleViewController is FR1)
    }

    func testFlowPresentsOnNavStackWhenNavHasNoRootAndNavigationStackLaunchStyle() {
        class FR1: TestViewController { }

        let nav = UINavigationController()
        nav.loadForTesting()

        nav.launchInto(Workflow(FR1.self, presentationType: .navigationStack), withLaunchStyle: .navigationStack)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        XCTAssertNil(nav.mostRecentlyPresentedViewController)
        XCTAssertNotNil(UIApplication.topViewController()?.navigationController)
        XCTAssert(UIApplication.topViewController()?.navigationController === nav)
        XCTAssertEqual(UIApplication.topViewController()?.navigationController?.viewControllers.count, 1)
        XCTAssert(UIApplication.topViewController()?.navigationController?.visibleViewController is FR1)
    }

    func testFlowThatSkipsScreen() {
        class FR1: TestViewController { }
        class FR2: TestViewController {
            override func shouldLoad() -> Bool { false }
        }
        class FR3: TestViewController { }

        let root = UIViewController()
        let nav = UINavigationController(rootViewController: root)
        nav.loadForTesting()

        root.launchInto(Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self))
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
    }

    func testFlowThatSkipsScreenIfThatScreenIsFirst() {
        class FR1: TestViewController {
            override func shouldLoad() -> Bool { false }
        }
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

        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController() as? FR3)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR4.self)
    }

    func testFlowThatSkipsScreenButStillPassesData() {
        class FR1: TestViewController { }
        class FR2: TestViewController {
            override func shouldLoad() -> Bool {
                proceedInWorkflow(data)
                return false
            }
        }
        class FR3: TestViewController { }

        let root = UIViewController()
        let nav = UINavigationController(rootViewController: root)
        nav.loadForTesting()

        root.launchInto(Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self))

        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow("worked")
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        XCTAssertEqual((UIApplication.topViewController() as? FR3)?.data as? String, "worked")
    }

    func testWorkflowLaunchingWorkflow() {
        class FR1: TestViewController { }
        class FR2: TestViewController {
            func launchSecondary() {
                let wf = Workflow(FR_1.self)
                launchInto(wf) { args in
                    self.data = args
                    wf.abandon(animated: false)
                }
            }
        }
        class FR3: TestViewController { }
        class FR_1: TestViewController { }

        let root = UIViewController()
        let nav = UINavigationController(rootViewController: root)
        nav.loadForTesting()

        root.launchInto(Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self))

        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.launchSecondary()
        XCTAssertUIViewControllerDisplayed(ofType: FR_1.self)
        class Obj { }
        let obj = Obj()
        (UIApplication.topViewController() as? FR_1)?.proceedInWorkflow(obj)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        XCTAssert((UIApplication.topViewController() as? FR2)?.data as? Obj === obj)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
    }

    func testNavWorkflowLaunchingModalWorkflow_Abandoning_ThenProceedingInNav() {
        class FR1: TestViewController { }
        class FR2: TestViewController {
            func launchSecondary() {
                let wf = Workflow(FR_1.self, presentationType: .modal)
                launchInto(wf) { args in
                    self.data = args
                    wf.abandon(animated: false)
                }
            }
        }
        class FR3: TestViewController { }
        class FR_1: TestViewController { }

        let nav = UINavigationController()
        nav.loadForTesting()

        nav.launchInto(Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self))

        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.launchSecondary()
        XCTAssertUIViewControllerDisplayed(ofType: FR_1.self)
        class Obj { }
        let obj = Obj()
        (UIApplication.topViewController() as? FR_1)?.proceedInWorkflow(obj)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        XCTAssert((UIApplication.topViewController() as? FR2)?.data as? Obj === obj)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
    }

    func testNavWorkflowLaunchingWorkflowModally_Abandoning_ThenProceedingInNav() {
        class FR1: TestViewController { }
        class FR2: TestViewController {
            func launchSecondary() {
                let wf = Workflow(FR_1.self)
                launchInto(wf, withLaunchStyle: .modal) { args in
                    self.data = args
                    wf.abandon(animated: false)
                }
            }
        }
        class FR3: TestViewController { }
        class FR_1: TestViewController { }

        let nav = UINavigationController()
        nav.loadForTesting()

        nav.launchInto(Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self))

        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.launchSecondary()
        XCTAssertUIViewControllerDisplayed(ofType: FR_1.self)
        class Obj { }
        let obj = Obj()
        (UIApplication.topViewController() as? FR_1)?.proceedInWorkflow(obj)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        XCTAssert((UIApplication.topViewController() as? FR2)?.data as? Obj === obj)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
    }

    func testNavWorkflowWhichSkipsAScreen_ButKeepsItInTheViewStack() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            required init(with args: Any?) { super.init(nibName: nil, bundle: nil) }
            required init?(coder: NSCoder) { nil }
            func shouldLoad() -> Bool { false }
        }
        class FR3: TestViewController { }

        let nav = UINavigationController()
        nav.loadForTesting()

        nav.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistence: .hiddenInitially)
                    .thenPresent(FR3.self), withLaunchStyle: .navigationStack)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController()?.navigationController)?.popViewController(animated: false)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
    }

    func testNavWorkflowWhichSkipsAScreen_ButKeepsItInTheViewStack_BacksUp_ThenGoesForwardAgain() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            required init(with args: Any?) { super.init(nibName: nil, bundle: nil) }
            required init?(coder: NSCoder) { nil }

            func shouldLoad() -> Bool { false }
        }
        class FR3: TestViewController { }

        let nav = UINavigationController()
        nav.loadForTesting()

        nav.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistence: .hiddenInitially)
                    .thenPresent(FR3.self), withLaunchStyle: .navigationStack)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController()?.navigationController)?.popViewController(animated: false)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
    }

    func testNavWorkflowWhichSkipsAScreen_ButKeepsItInTheViewStack_BacksUpUsingWorkflow_ThenGoesForwardAgain() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            required init(with args: Any?) { super.init(nibName: nil, bundle: nil) }
            required init?(coder: NSCoder) { nil }
            func shouldLoad() -> Bool { false }
        }
        class FR3: TestViewController { }

        let nav = UINavigationController()
        nav.loadForTesting()

        nav.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistence: .hiddenInitially)
                    .thenPresent(FR3.self), withLaunchStyle: .navigationStack)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        try? (UIApplication.topViewController() as? FR3)?.backUpInWorkflow()
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
    }

    func testNavWorkflowWhichSkipsFirstScreen_ButKeepsItInTheViewStack() {
        class FR1: TestViewController {
            override func shouldLoad() -> Bool { false }
        }
        final class FR2: UIWorkflowItem<Never, Any?>, FlowRepresentable { }
        class FR3: TestViewController { }

        let nav = UINavigationController()
        nav.loadForTesting()

        nav.launchInto(Workflow(FR1.self, flowPersistence: .hiddenInitially)
                    .thenPresent(FR2.self)
                    .thenPresent(FR3.self), withLaunchStyle: .navigationStack)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController()?.navigationController)?.popViewController(animated: false)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
    }

    func testNavWorkflowWhichSkipsFirstScreen_ButKeepsItInTheViewStack_BacksUp_ThenGoesForwardAgain() {
        class FR1: TestViewController {
            override func shouldLoad() -> Bool { false }
        }
        final class FR2: UIWorkflowItem<Never, Any?>, FlowRepresentable { }
        class FR3: TestViewController { }

        let nav = UINavigationController()
        nav.loadForTesting()

        nav.launchInto(Workflow(FR1.self, flowPersistence: .hiddenInitially)
                    .thenPresent(FR2.self)
                    .thenPresent(FR3.self), withLaunchStyle: .navigationStack)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController()?.navigationController)?.popViewController(animated: false)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
    }

    func testNavWorkflowWhichDoesNotSkipAScreen_ButRemovesItFromTheViewStack() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            required init(with args: Any?) { super.init(nibName: nil, bundle: nil) }
            required init?(coder: NSCoder) { nil }
        }
        class FR3: TestViewController { }

        let nav = UINavigationController()
        nav.loadForTesting()

        nav.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistence: .removedAfterProceeding)
                    .thenPresent(FR3.self), withLaunchStyle: .navigationStack)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController()?.navigationController)?.popViewController(animated: false)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
    }

    func testNavWorkflowWhichDoesNotSkipFirstScreen_ButRemovesItFromTheViewStack() {
        class FR1: TestViewController { }
        final class FR2: UIWorkflowItem<Never, Any?>, FlowRepresentable { }
        class FR3: TestViewController { }

        let nav = UINavigationController()
        nav.loadForTesting()

        nav.launchInto(Workflow(FR1.self, flowPersistence: .removedAfterProceeding)
                    .thenPresent(FR2.self)
                    .thenPresent(FR3.self), withLaunchStyle: .navigationStack)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        XCTAssert(UIApplication.topViewController()?.navigationController?.viewControllers.first is FR2)
    }

    func testNavWorkflowWhichSkipsAScreen_ButKeepsItInTheViewStackUsingAClosure() {
        class FR1: TestViewController { }
        final class FR2: UIWorkflowItem<Never, Any?>, FlowRepresentable {
            func shouldLoad() -> Bool { false }
        }
        class FR3: TestViewController { }

        let nav = UINavigationController()
        nav.loadForTesting()

        nav.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistence: .hiddenInitially)
                    .thenPresent(FR3.self), withLaunchStyle: .navigationStack)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController()?.navigationController)?.popViewController(animated: false)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
    }

    func testNavWorkflowWhichDoesNotSkipAScreen_ButRemovesItFromTheViewStackUsingAClosure() {
        class FR1: TestViewController { }
        final class FR2: UIWorkflowItem<Never, Any?>, FlowRepresentable { }
        class FR3: TestViewController { }

        let nav = UINavigationController()
        nav.loadForTesting()

        nav.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistence: .removedAfterProceeding)
                    .thenPresent(FR3.self), withLaunchStyle: .navigationStack)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController()?.navigationController)?.popViewController(animated: false)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
    }

    func testNavWorkflowWhichSkipsAScreen_ButKeepsItInTheViewStackUsingAClosureWithData() {
        class FR1: TestViewController { }
        final class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            init(with args: Any?) { super.init(nibName: nil, bundle: nil) }
            required init?(coder: NSCoder) { nil }
            func shouldLoad() -> Bool { false }
        }
        class FR3: TestViewController { }

        let nav = UINavigationController()
        nav.loadForTesting()

        nav.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistence: { _ in .hiddenInitially })
                    .thenPresent(FR3.self), withLaunchStyle: .navigationStack)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow("blah")
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController()?.navigationController)?.popViewController(animated: false)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
    }

    func testNavWorkflowWhichDoesNotSkipAScreen_ButRemovesItFromTheViewStackUsingAClosureWithData() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            required init(with args: Any?) { super.init(nibName: nil, bundle: nil) }
            required init?(coder: NSCoder) { nil }
        }
        class FR3: TestViewController { }

        let nav = UINavigationController()
        nav.loadForTesting()

        nav.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistence: { data in
                        XCTAssertEqual(data as? String, "blah")
                        return .removedAfterProceeding
                    })
                    .thenPresent(FR3.self), withLaunchStyle: .navigationStack)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow("blah")
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController()?.navigationController)?.popViewController(animated: false)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
    }

    func testModalWorkflowWhichSkipsAScreen_ButKeepsItInTheViewStack() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            required init(with args: Any?) { super.init(nibName: nil, bundle: nil) }
            required init?(coder: NSCoder) { nil }
            func shouldLoad() -> Bool { false }
        }
        class FR3: TestViewController { }

        let root = UIViewController()
        root.loadForTesting()

        root.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistence: .hiddenInitially)
                    .thenPresent(FR3.self), withLaunchStyle: .modal)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        UIApplication.topViewController()?.dismiss(animated: true)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
    }

    func testModalWorkflowWhichSkipsAScreen_andBacksUpWithWorkflow() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            required init(with args: Any?) { super.init(nibName: nil, bundle: nil) }
            required init?(coder: NSCoder) { nil }
            func shouldLoad() -> Bool { false }
        }
        class FR3: TestViewController { }

        let root = UIViewController()
        root.loadForTesting()

        root.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self)
                    .thenPresent(FR3.self), withLaunchStyle: .modal)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        try? (UIApplication.topViewController() as? FR3)?.backUpInWorkflow()
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
    }

    func testModalWorkflowWhichSkipsAScreen_ButKeepsItInTheViewStack_andBacksUpWithWorkflow() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            required init(with args: Any?) { super.init(nibName: nil, bundle: nil) }
            required init?(coder: NSCoder) { nil }
            func shouldLoad() -> Bool { false }
        }
        class FR3: TestViewController { }

        let root = UIViewController()
        root.loadForTesting()

        root.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistence: .hiddenInitially)
                    .thenPresent(FR3.self), withLaunchStyle: .modal)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        try? (UIApplication.topViewController() as? FR3)?.backUpInWorkflow()
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
    }

    func testModalWorkflowWhichSkipsFirstScreen_ButKeepsItInTheViewStack() {
        class FR1: TestViewController {
            override func shouldLoad() -> Bool { false }
        }
        final class FR2: UIWorkflowItem<Never, Any?>, FlowRepresentable {
            static func instance() -> Self { Self() }
        }
        class FR3: TestViewController { }

        let root = UIViewController()
        root.loadForTesting()

        root.launchInto(Workflow(FR1.self, flowPersistence: .hiddenInitially)
                    .thenPresent(FR2.self)
                    .thenPresent(FR3.self), withLaunchStyle: .modal)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        UIApplication.topViewController()?.dismiss(animated: false)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
    }

    func testModalWorkflowWhichDoesNotSkipAScreen_ButRemovesItFromTheViewStack() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            required init(with args: Any?) { super.init(nibName: nil, bundle: nil) }
            required init?(coder: NSCoder) { nil }
        }
        class FR3: TestViewController { }

        let root = UIViewController()
        root.loadForTesting()

        root.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistence: .removedAfterProceeding)
                    .thenPresent(FR3.self), withLaunchStyle: .modal)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        UIApplication.topViewController()?.dismiss(animated: true)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
    }

    func testModalWorkflowWhichDoesNotSkipFirstScreen_ButRemovesItFromTheViewStack() {
        class FR1: TestViewController { }
        final class FR2: UIWorkflowItem<Never, Any?>, FlowRepresentable { }
        class FR3: TestViewController { }

        let root = UIViewController()
        root.loadForTesting()

        root.launchInto(Workflow(FR1.self, flowPersistence: .removedAfterProceeding)
                    .thenPresent(FR2.self)
                    .thenPresent(FR3.self), withLaunchStyle: .modal)

        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        UIApplication.topViewController()?.dismiss(animated: true)
        XCTAssertUIViewControllerDisplayed(isInstance: root)
    }

    func testModalWorkflowWhichSkipsAScreen_ButKeepsItInTheViewStackUsingAClosure() {
        class FR1: TestViewController { }
        final class FR2: UIWorkflowItem<Never, Any?>, FlowRepresentable {
            func shouldLoad() -> Bool { false }
        }
        class FR3: TestViewController { }

        let root = UIViewController()
        root.loadForTesting()

        root.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistence: .hiddenInitially)
                    .thenPresent(FR3.self), withLaunchStyle: .modal)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        UIApplication.topViewController()?.dismiss(animated: true)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
    }

    func testModalWorkflowWhichDoesNotSkipAScreen_ButRemovesItFromTheViewStackUsingAClsure() {
        class FR1: TestViewController { }
        final class FR2: UIWorkflowItem<Never, Any?>, FlowRepresentable { }
        class FR3: TestViewController { }

        let root = UIViewController()
        root.loadForTesting()

        root.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistence: .removedAfterProceeding)
                    .thenPresent(FR3.self), withLaunchStyle: .modal)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        UIApplication.topViewController()?.dismiss(animated: true)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
    }

    func testModalWorkflowWhichSkipsAScreen_ButKeepsItInTheViewStackUsingAClosureWithData() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            required init(with args: Any?) { super.init(nibName: nil, bundle: nil) }
            required init?(coder: NSCoder) { nil }
            func shouldLoad() -> Bool { false }
        }
        class FR3: TestViewController { }

        let root = UIViewController()
        root.loadForTesting()

        root.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistence: { _ in .hiddenInitially })
                    .thenPresent(FR3.self), withLaunchStyle: .modal)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow("blah")
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        UIApplication.topViewController()?.dismiss(animated: true)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
    }

    func testModalWorkflowWhichDoesNotSkipAScreen_ButRemovesItFromTheViewStackUsingAClosureWithData() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            required init(with args: Any?) { super.init(nibName: nil, bundle: nil) }
            required init?(coder: NSCoder) { nil }
        }
        class FR3: TestViewController { }

        let root = UIViewController()
        root.loadForTesting()

        root.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistence: { data in
                        XCTAssertEqual(data as? String, "blah")
                        return .removedAfterProceeding
                    })
                    .thenPresent(FR3.self), withLaunchStyle: .modal)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow("blah")
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        UIApplication.topViewController()?.dismiss(animated: true)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
    }

    func testNavWorkflowLaunchingNewWorkflowWithNavigationStack_Abandoning_ThenProceedingInNav() {
        class FR1: TestViewController { }
        class FR2: TestViewController {
            func launchSecondary() {
                let wf = Workflow(FR_1.self)
                launchInto(wf, withLaunchStyle: .navigationStack) { args in
                    self.data = args
                    wf.abandon(animated: false)
                }
            }
        }
        class FR3: TestViewController { }
        class FR_1: TestViewController { }

        let nav = UINavigationController()
        nav.loadForTesting()

        nav.launchInto(Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self))

        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.launchSecondary()
        XCTAssertUIViewControllerDisplayed(ofType: FR_1.self)
        class Obj { }
        let obj = Obj()
        (UIApplication.topViewController() as? FR_1)?.proceedInWorkflow(obj)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        XCTAssert((UIApplication.topViewController() as? FR2)?.data as? Obj === obj)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
    }

    func testCallingThroughMultipleSkippedWorkflowItems() {
        class FR1: TestViewController {
            override func shouldLoad() -> Bool {
                proceedInWorkflow(data)
                return false
            }
        }
        class FR2: TestViewController {
            override func shouldLoad() -> Bool {
                proceedInWorkflow(data)
                return false
            }
        }
        class FR3: TestViewController {
            override func shouldLoad() -> Bool {
                proceedInWorkflow(data)
                return false
            }
        }
        class FR4: TestViewController { }
        class Obj { }
        let obj = Obj()

        let root = UIViewController()
        let nav = UINavigationController(rootViewController: root)
        nav.loadForTesting()

        root.launchInto(Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)
            .thenPresent(FR4.self), args: obj)
        XCTAssertUIViewControllerDisplayed(ofType: FR4.self)
        XCTAssert((UIApplication.topViewController() as? FR4)?.data as? Obj === obj)
    }

    func testStartWithEmptyNav_LaunchWorkflowThatSkipsTheFirstScreenAndPassesData() {
        class FR1: TestViewController {
            override func shouldLoad() -> Bool {
                proceedInWorkflow(data)
                return false
            }
        }
        class FR2: TestViewController { }
        class Obj { }
        let obj = Obj()

        let nav = UINavigationController()
        nav.loadForTesting()

        nav.launchInto(Workflow(FR1.self)
            .thenPresent(FR2.self), args: obj)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        XCTAssert((UIApplication.topViewController() as? FR2)?.data as? Obj === obj)
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
            XCTAssert(args as? Obj === obj)
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

    func testFinishingWorkflowCallsBackEvenIfLastViewIsSkipped() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        class FR4: TestViewController {
            override func shouldLoad() -> Bool { false }
        }

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
            XCTAssert(args as? Obj === obj)
        }
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.next()
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.next()
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController() as? FR3)?.next()
        XCTAssert(callbackCalled)
    }

    static var viewDidLoadOnMockCalled = 0
    func testViewDidLoadGetsCalledWhereAppropriate() {
        UIKitConsumerTests.viewDidLoadOnMockCalled = 0

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

    func testWorkflowLaunchModally() {
        class ExpectedModal: UIWorkflowItem<Never, Never>, FlowRepresentable {
            required init() {
                super.init(nibName: nil, bundle: nil)
                view.backgroundColor = .green
            }

            required init?(coder: NSCoder) { nil }
        }

        let rootController = UIViewController()
        let controller = UINavigationController(rootViewController: rootController)
        controller.loadForTesting()

        rootController.launchInto(Workflow(ExpectedModal.self), withLaunchStyle: .modal)

        RunLoop.current.singlePass()

        XCTAssertEqual(controller.viewControllers.count, 1)
        XCTAssert(rootController.mostRecentlyPresentedViewController is ExpectedModal, "mostRecentlyPresentedViewController should be ExpectedModal: \(String(describing: controller.mostRecentlyPresentedViewController))")
    }

    func testWorkflowLaunchModallyButSecondViewPrefersANavController() {
        class ExpectedModal: UIWorkflowItem<Never, Never>, FlowRepresentable {
            required init() {
                super.init(nibName: nil, bundle: nil)
                view.backgroundColor = .green
            }

            required init?(coder: NSCoder) { nil }

            override func viewDidAppear(_ animated: Bool) {
                proceedInWorkflow()
            }
        }

        class ExpectedModalPreferNav: UIWorkflowItem<Never, Never>, FlowRepresentable {
            required init() {
                super.init(nibName: nil, bundle: nil)
                view.backgroundColor = .blue
            }

            required init?(coder: NSCoder) { nil }
        }

        let rootController = UIViewController()
        let controller = UINavigationController(rootViewController: rootController)
        controller.loadForTesting()

        rootController.launchInto(Workflow(ExpectedModal.self)
            .thenPresent(ExpectedModalPreferNav.self, presentationType: .navigationStack),
                                  withLaunchStyle: .modal)
        RunLoop.current.singlePass()

        XCTAssertEqual(controller.viewControllers.count, 1)
        XCTAssert(rootController.mostRecentlyPresentedViewController is ExpectedModal, "mostRecentlyPresentedViewController should be ExpectedModal: \(String(describing: controller.mostRecentlyPresentedViewController))")
        XCTAssertUIViewControllerDisplayed(ofType: ExpectedModalPreferNav.self)
        XCTAssertNotNil(UIApplication.topViewController()?.navigationController)
    }

    func testFluentWorkflowLaunchModallyButSecondViewPrefersANavController() {
        class ExpectedModal: UIWorkflowItem<Never, Never>, FlowRepresentable {
            required init() {
                super.init(nibName: nil, bundle: nil)
                view.backgroundColor = .green
            }

            required init?(coder: NSCoder) { nil }

            override func viewDidAppear(_ animated: Bool) {
                proceedInWorkflow()
            }
        }

        class ExpectedModalPreferNav: UIWorkflowItem<Never, Never>, FlowRepresentable {
            required init() {
                super.init(nibName: nil, bundle: nil)
                view.backgroundColor = .blue
            }

            required init?(coder: NSCoder) { nil }
        }

        let rootController = UIViewController()
        let controller = UINavigationController(rootViewController: rootController)
        controller.loadForTesting()

        rootController.launchInto(
            Workflow(ExpectedModal.self)
                .thenPresent(ExpectedModalPreferNav.self,
                      presentationType: .navigationStack),
            withLaunchStyle: .modal)
        RunLoop.current.singlePass()

        XCTAssertEqual(controller.viewControllers.count, 1)
        XCTAssert(rootController.mostRecentlyPresentedViewController is ExpectedModal, "mostRecentlyPresentedViewController should be ExpectedModal: \(String(describing: controller.mostRecentlyPresentedViewController))")
        XCTAssertUIViewControllerDisplayed(ofType: ExpectedModalPreferNav.self)
        XCTAssertNotNil(UIApplication.topViewController()?.navigationController)
    }

    func testWorkflowLaunchModallyButFirstViewHasANavController() {
        class ExpectedModal: UIWorkflowItem<Never, Never>, FlowRepresentable {
            required init() {
                super.init(nibName: nil, bundle: nil)
                view.backgroundColor = .green
            }

            required init?(coder: NSCoder) { nil }
        }

        let firstView = UIViewController()
        let rootController = UIViewController()
        let controller = UINavigationController(rootViewController: rootController)
        firstView.loadForTesting()
        firstView.present(controller, animated: false)

        let workflow = Workflow(ExpectedModal.self, presentationType: .navigationStack)

        rootController.launchInto(workflow, withLaunchStyle: .modal)
        RunLoop.current.singlePass()

        XCTAssertEqual(controller.viewControllers.count, 1)
        XCTAssert(rootController.mostRecentlyPresentedViewController is UINavigationController, "mostRecentlyPresentedViewController should be UINavigationController: \(String(describing: rootController.mostRecentlyPresentedViewController))")
        XCTAssertEqual((rootController.mostRecentlyPresentedViewController as? UINavigationController)?.viewControllers.count, 1)
        XCTAssert((rootController.mostRecentlyPresentedViewController as? UINavigationController)?.viewControllers.first is ExpectedModal, "rootViewController should be ExpectedModal: \(String(describing: (rootController.mostRecentlyPresentedViewController as? UINavigationController)?.viewControllers.first))")
    }

    func testFluentWorkflowLaunchModallyButFirstViewHasANavController() {
        class ExpectedNav: UIWorkflowItem<Never, Never>, FlowRepresentable {
            required init() {
                super.init(nibName: nil, bundle: nil)
                view.backgroundColor = .green
            }

            required init?(coder: NSCoder) { nil }
        }

        let firstView = UIViewController()
        let rootController = UIViewController()
        let controller = UINavigationController(rootViewController: rootController)
        firstView.loadForTesting()
        firstView.present(controller, animated: false)

        let workflow = Workflow(ExpectedNav.self, presentationType: .navigationStack)
        rootController.launchInto(workflow, withLaunchStyle: .modal)
        RunLoop.current.singlePass()

        XCTAssertEqual(controller.viewControllers.count, 1)
        XCTAssert(rootController.mostRecentlyPresentedViewController is UINavigationController, "mostRecentlyPresentedViewController should be UINavigationController: \(String(describing: rootController.mostRecentlyPresentedViewController))")
        XCTAssertEqual((rootController.mostRecentlyPresentedViewController as? UINavigationController)?.viewControllers.count, 1)
        XCTAssert((rootController.mostRecentlyPresentedViewController as? UINavigationController)?.viewControllers.first is ExpectedNav, "rootViewController should be ExpectedNav: \(String(describing: (rootController.mostRecentlyPresentedViewController as? UINavigationController)?.viewControllers.first))")
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
        XCTAssertTrue(UIKitConsumerTests.testCallbackCalled)
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
        XCTAssertTrue(UIKitConsumerTests.testCallbackCalled)
    }

    func testWorkflowAbandonWhenNoNavigationControllerExists() {
        let rootController = UIViewController()
        rootController.loadForTesting()

        let workflow = Workflow(TestViewController.self)

        rootController.launchInto(workflow)

        XCTAssertUIViewControllerDisplayed(ofType: TestViewController.self)

        workflow.abandon(animated: false, onFinish: testCallback)

        XCTAssertUIViewControllerDisplayed(isInstance: rootController)
        XCTAssertTrue(UIKitConsumerTests.testCallbackCalled)
    }

    func testWorkflowAbandonWhenLaunchStyleIsNavigationStack() {
        let rootController = UIViewController()
        rootController.loadForTesting()

        let workflow = Workflow(TestViewController.self)

        rootController.launchInto(workflow, withLaunchStyle: .navigationStack)

        XCTAssertUIViewControllerDisplayed(ofType: TestViewController.self)

        workflow.abandon(animated: false, onFinish: testCallback)

        XCTAssertUIViewControllerDisplayed(isInstance: rootController)
        XCTAssertTrue(UIKitConsumerTests.testCallbackCalled)
    }

    func testAbandonWhenWorkflowHasNavPresentingSubsequentViewsModally() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        class FR4: TestViewController { }

        let root = UIViewController()
        root.loadForTesting()

        root.launchInto(Workflow(FR1.self)
            .thenPresent(FR2.self, presentationType: .modal)
            .thenPresent(FR3.self)
            .thenPresent(FR4.self), withLaunchStyle: .navigationStack)

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

    func testAbandonWhenFluentWorkflowHasNavPresentingSubsequentViewsModally() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        class FR4: TestViewController { }

        let root = UIViewController()
        root.loadForTesting()
        root.launchInto(
            Workflow(FR1.self)
                .thenPresent(FR2.self, presentationType: .modal)
                .thenPresent(FR3.self)
                .thenPresent(FR4.self),
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
            .thenPresent(FR2.self, presentationType: .modal)
            .thenPresent(FR3.self, presentationType: .navigationStack)
            .thenPresent(FR4.self, presentationType: .modal),
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
                .thenPresent(FR2.self, presentationType: .modal)
                .thenPresent(FR3.self, presentationType: .navigationStack)
                .thenPresent(FR4.self, presentationType: .modal),
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
            .thenPresent(FR2.self, presentationType: .modal)
            .thenPresent(FR3.self, presentationType: .navigationStack)
            .thenPresent(FR4.self, presentationType: .modal),
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

    func testWorkflowLaunchModallyButFirstViewHasANavControllerAndThenDismiss() {
        class ExpectedModal: UIWorkflowItem<Never, Never>, FlowRepresentable {
            required init() {
                super.init(nibName: nil, bundle: nil)
                view.backgroundColor = .green
            }

            required init?(coder: NSCoder) { nil }
        }
        let rootController = UIViewController()
        let controller = UINavigationController(rootViewController: rootController)
        controller.loadForTesting()

        let workflow = Workflow(TestViewController.self)
            .thenPresent(ExpectedModal.self, presentationType: .modal)

        rootController.launchInto(workflow)

        XCTAssertUIViewControllerDisplayed(ofType: TestViewController.self)
        (UIApplication.topViewController() as? TestViewController)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: ExpectedModal.self)

        workflow.abandon(animated: false, onFinish: testCallback)

        XCTAssertUIViewControllerDisplayed(isInstance: rootController)
        XCTAssertTrue(UIKitConsumerTests.testCallbackCalled)
    }

    func testWorkflowLaunchWithNavigationStack() {
        class ExpectedController: UIWorkflowItem<Never, Never>, FlowRepresentable {
            required init() {
                super.init(nibName: nil, bundle: nil)
                view.backgroundColor = .green
            }

            required init?(coder: NSCoder) { nil }
        }

        let rootController = UIViewController()
        let controller = UINavigationController(rootViewController: rootController)
        controller.loadForTesting()

        rootController.launchInto(Workflow(ExpectedController.self), withLaunchStyle: .navigationStack)
        RunLoop.current.singlePass()

        XCTAssertEqual(controller.viewControllers.count, 2)
        XCTAssertFalse(rootController.mostRecentlyPresentedViewController is ExpectedController, "mostRecentlyPresentedViewController should not be ExpectedModal: \(String(describing: controller.mostRecentlyPresentedViewController))")
    }

    func testWorkflowLaunchWithNavigationStackWhenLauncherDoesNotHavNavController() {
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

    func testWorkflowLaunchesWithNavButHasAViewThatPrefersModalBecauseItCan() {
        class ExpectedModal: UIWorkflowItem<Never, Never>, FlowRepresentable {
            required init() {
                super.init(nibName: nil, bundle: nil)
                view.backgroundColor = .green
            }

            required init?(coder: NSCoder) { nil }
        }
        class ExpectedNav: UIWorkflowItem<Never, Never>, FlowRepresentable {
            required init() {
                super.init(nibName: nil, bundle: nil)
                view.backgroundColor = .blue
            }

            required init?(coder: NSCoder) { nil }
        }
        let rootController = UIViewController()
        let controller = UINavigationController(rootViewController: rootController)
        controller.loadForTesting()

        rootController.launchInto(Workflow(ExpectedNav.self)
            .thenPresent(ExpectedModal.self, presentationType: .modal))

        XCTAssertUIViewControllerDisplayed(ofType: ExpectedNav.self)
        XCTAssertEqual(controller.viewControllers.count, 2)
        (UIApplication.topViewController() as? ExpectedNav)?.proceedInWorkflow()
        XCTAssertUIViewControllerDisplayed(ofType: ExpectedModal.self)
        XCTAssertNil((UIApplication.topViewController() as? ExpectedModal)?.navigationController, "You didn't present modally")
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
}

extension UIKitConsumerTests {
    class TestViewController: UIWorkflowItem<AnyWorkflow.PassedArgs, Any?>, FlowRepresentable {
        var data: Any?
        required init(with args: AnyWorkflow.PassedArgs) {
            super.init(nibName: nil, bundle: nil)
            view.backgroundColor = .red
            data = args.extract(nil)
        }

        required init?(coder: NSCoder) { nil }

        // See important documentation on FlowRepresentable
        func shouldLoad() -> Bool { true }

        func next() {
            proceedInWorkflow(data)
        }
    }
}

final class MockFlowRepresentable: UIWorkflowItem<Never, Never>, FlowRepresentable {
    // The protocol synthesizes a shouldLoad function that returns true. The super class (this) is considered to have it by Swift.  When you inherit and declare it again, Swift considers the subclass to not have overwritten but instead declared a new function.  By declaring here we say that we don't care about the synthesized function and our subclass can then override.  This only matters if your superclass is a FlowRepresentable.
    func shouldLoad() -> Bool { true }

    override func viewDidLoad() {
        UIKitConsumerTests.viewDidLoadOnMockCalled += 1
    }
}
