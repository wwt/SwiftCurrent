//
//  UIKitPresenterTests.swift
//  WorkflowTests
//
//  Created by Tyler Thompson on 8/26/19.
//  Copyright © 2019 Tyler Tompson. All rights reserved.
//

import Foundation
import XCTest

@testable import Workflow
@testable import WorkflowUIKit

class UIKitPresenterTests: XCTestCase {
    override func setUpWithError() throws {
        UIView.setAnimationsEnabled(false)
        UIViewController.initializeTestable()
    }

    override func tearDownWithError() throws {
        UIView.setAnimationsEnabled(true)
    }

    func testWorkflowCanLaunchViewController() {
        class FR1: UIViewController, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?

            typealias WorkflowInput = Never

            static func instance() -> Self { Self() }
        }
        let flow = Workflow(FR1.self)

        let root = UIViewController()
        loadView(controller: root)

        root.launchInto(flow)

        XCTAssert(UIApplication.topViewController() is FR1)
    }

    func testWorkflowCanSkipTheFirstView() {
        class FR1: UIViewController, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?

            typealias WorkflowInput = String?
            typealias WorkflowOutput = Int?

            static func instance() -> Self { Self() }

            func shouldLoad(with args: String?) -> Bool {
                proceedInWorkflow(1)
                return false
            }
        }
        class FR2: UIViewController, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?

            typealias WorkflowInput = Int?

            static func instance() -> Self { Self() }

            func shouldLoad(with args: Int?) -> Bool { true }
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
            weak var _workflowPointer: AnyFlowRepresentable?

            typealias WorkflowInput = Never

            static func instance() -> Self {
                let vc = Self()
                vc.view.backgroundColor = .green
                return vc
            }
        }
        let root = UIViewController()
        root.view.backgroundColor = .blue
        let nav = UINavigationController(rootViewController: root)
        loadView(controller: nav)

        root.launchInto(Workflow(FR1.self))

        XCTAssert(UIApplication.topViewController() is FR1)
        XCTAssert(nav.visibleViewController is FR1)
        XCTAssert(nav.viewControllers.last is FR1)
    }

    func testAbandonWorkflowWithoutNavigationController() {
        class FR1: UIViewController, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?

            typealias WorkflowInput = Never

            static func instance() -> Self {
                let vc = Self()
                vc.view.backgroundColor = .green
                return vc
            }
        }

        let root = UIViewController()
        root.view.backgroundColor = .blue
        loadView(controller: root)

        let wf = Workflow(FR1.self)

        root.launchInto(wf)

        waitUntil(UIApplication.topViewController() is FR1)

        (UIApplication.topViewController() as? FR1)?.abandonWorkflow()

        waitUntil(!(UIApplication.topViewController() is FR1))

        XCTAssert(UIApplication.topViewController() === root)
    }

    func testAbandonWorkflowWithNavigationController() {
        class FR1: UIViewController, FlowRepresentable {
            typealias WorkflowInput = Never

            weak var _workflowPointer: AnyFlowRepresentable?

            static func instance() -> Self {
                let vc = Self()
                vc.view.backgroundColor = .green
                return vc
            }
        }

        let root = UIViewController()
        root.view.backgroundColor = .blue
        let nav = UINavigationController(rootViewController: root)
        loadView(controller: nav)

        let wf = Workflow(FR1.self)

        root.launchInto(wf)

        waitUntil(UIApplication.topViewController() is FR1)

        (UIApplication.topViewController() as? FR1)?.abandonWorkflow()

        waitUntil(!(UIApplication.topViewController() is FR1))

        XCTAssert(UIApplication.topViewController() === root)
    }

    func testAbandonWorkflowWithNavigationControllerWhichHasSomeViewControllersAlready() {
        class FR1: UIViewController, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?

            typealias WorkflowInput = Never

            static func instance() -> Self {
                let vc = Self()
                vc.view.backgroundColor = .green
                return vc
            }
        }

        let root = UIViewController()
        root.view.backgroundColor = .blue
        let second = UIViewController()
        root.view.backgroundColor = .red
        let nav = UINavigationController(rootViewController: root)
        nav.pushViewController(second, animated: false)
        loadView(controller: nav)

        let wf = Workflow(FR1.self)

        root.launchInto(wf)

        waitUntil(UIApplication.topViewController() is FR1)

        (UIApplication.topViewController() as? FR1)?.abandonWorkflow()

        waitUntil(!(UIApplication.topViewController() is FR1))

        XCTAssert(UIApplication.topViewController() === second)
    }

    func testLaunchWorkflowWithArguments() {
        class FR1: UIWorkflowItem<Int, Never>, FlowRepresentable {
            static var shouldLoadCalled = false
            static func instance() -> Self {
                let vc = Self()
                vc.view.backgroundColor = .green
                return vc
            }

            func shouldLoad(with args: Int) -> Bool {
                FR1.shouldLoadCalled = true
                return true
            }
        }

        let root = UIViewController()
        root.view.backgroundColor = .blue
        loadView(controller: root)

        let wf = Workflow(FR1.self)

        root.launchInto(wf, args: 1)

        waitUntil(UIApplication.topViewController() is FR1)

        XCTAssert(FR1.shouldLoadCalled)
    }

    func testCreateViewControllerWithBaseClassForEase() {
        class FR1: UIWorkflowItem<Int, Never>, FlowRepresentable {
            static var shouldLoadCalled = false
            static func instance() -> Self {
                let vc = Self()
                vc.view.backgroundColor = .green
                return vc
            }

            func shouldLoad(with args: Int) -> Bool {
                FR1.shouldLoadCalled = true
                return true
            }
        }

        let root = UIViewController()
        root.view.backgroundColor = .blue
        loadView(controller: root)

        let wf = Workflow(FR1.self)

        root.launchInto(wf, args: 20000)

        waitUntil(UIApplication.topViewController() is FR1)

        XCTAssert(FR1.shouldLoadCalled)
    }

    private func loadView(controller: UIViewController) {
        let window = UIApplication.shared.windows.first
        window?.removeViewsFromRootViewController()

        window?.rootViewController = controller
        controller.loadViewIfNeeded()
        controller.view.layoutIfNeeded()

        controller.viewWillAppear(false)
        controller.viewDidAppear(false)

        CATransaction.flush()
    }

    static var testCallbackCalled = false
    let testCallback = {
        UIKitPresenterTests.testCallbackCalled = true
    }
    override func setUp() {
        UIKitPresenterTests.testCallbackCalled = false
        UIKitPresenterTests.viewDidLoadOnMockCalled = 0
        UIViewController.initializeTestable()
        UIView.setAnimationsEnabled(false)
    }

    override func tearDown() {
        UIViewController.flushPendingTestArtifacts()
    }

    func testFlowCanBeFullyFollowed() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        class FR4: TestViewController { }

        let root = UIViewController()
        let nav = UINavigationController(rootViewController: root)
        loadView(controller: nav)

        root.launchInto(Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)
            .thenPresent(FR4.self))

        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        (UIApplication.topViewController() as? FR3)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR4)
        XCTAssert(UIApplication.topViewController() is FR4)
    }

    func testFlowPresentsOnNavStackWhenNavHasNoRoot() {
        class FR1: TestViewController { }

        let nav = UINavigationController()
        loadView(controller: nav)

        nav.launchInto(Workflow(FR1.self))
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        XCTAssertNil(nav.mostRecentlyPresentedViewController)
        XCTAssertNotNil(UIApplication.topViewController()?.navigationController)
        XCTAssertEqual(UIApplication.topViewController()?.navigationController?.viewControllers.count, 1)
        XCTAssert(UIApplication.topViewController()?.navigationController?.visibleViewController is FR1)
    }

    func testFlowPresentsOnNavStackWhenNavHasNoRootAndNavigationStackLaunchStyle() {
        class FR1: TestViewController { }

        let nav = UINavigationController()
        loadView(controller: nav)

        nav.launchInto(Workflow(FR1.self, presentationType: .navigationStack), withLaunchStyle: .navigationStack)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        XCTAssertNil(nav.mostRecentlyPresentedViewController)
        XCTAssertNotNil(UIApplication.topViewController()?.navigationController)
        XCTAssert(UIApplication.topViewController()?.navigationController === nav)
        XCTAssertEqual(UIApplication.topViewController()?.navigationController?.viewControllers.count, 1)
        XCTAssert(UIApplication.topViewController()?.navigationController?.visibleViewController is FR1)
    }

    func testFlowThatSkipsScreen() {
        class FR1: TestViewController { }
        class FR2: TestViewController {
            override func shouldLoad(with args: AnyWorkflow.PassedArgs) -> Bool { false }
        }
        class FR3: TestViewController { }

        let root = UIViewController()
        let nav = UINavigationController(rootViewController: root)
        loadView(controller: nav)

        root.launchInto(Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self))
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
    }

    func testFlowThatSkipsScreenIfThatScreenIsFirst() {
        class FR1: TestViewController {
            override func shouldLoad(with args: AnyWorkflow.PassedArgs) -> Bool { false }
        }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        class FR4: TestViewController { }

        let root = UIViewController()
        let nav = UINavigationController(rootViewController: root)
        loadView(controller: nav)

        root.launchInto(Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)
            .thenPresent(FR4.self))

        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        (UIApplication.topViewController() as? FR3)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR4)
        XCTAssert(UIApplication.topViewController() is FR4)
    }

    func testFlowThatSkipsScreenButStillPassesData() {
        class FR1: TestViewController { }
        class FR2: TestViewController {
            override func shouldLoad(with args: AnyWorkflow.PassedArgs) -> Bool {
                proceedInWorkflow(args.extract(nil))
                return false
            }
        }
        class FR3: TestViewController { }

        let root = UIViewController()
        let nav = UINavigationController(rootViewController: root)
        loadView(controller: nav)

        root.launchInto(Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self))

        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow("worked")
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
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
        loadView(controller: nav)

        root.launchInto(Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self))

        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        (UIApplication.topViewController() as? FR2)?.launchSecondary()
        waitUntil(UIApplication.topViewController() is FR_1)
        class Obj { }
        let obj = Obj()
        (UIApplication.topViewController() as? FR_1)?.proceedInWorkflow(obj)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert((UIApplication.topViewController() as? FR2)?.data as? Obj === obj)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
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
        loadView(controller: nav)

        nav.launchInto(Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self))

        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        (UIApplication.topViewController() as? FR2)?.launchSecondary()
        waitUntil(UIApplication.topViewController() is FR_1)
        class Obj { }
        let obj = Obj()
        (UIApplication.topViewController() as? FR_1)?.proceedInWorkflow(obj)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert((UIApplication.topViewController() as? FR2)?.data as? Obj === obj)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
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
        loadView(controller: nav)

        nav.launchInto(Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self))

        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        (UIApplication.topViewController() as? FR2)?.launchSecondary()
        waitUntil(UIApplication.topViewController() is FR_1)
        class Obj { }
        let obj = Obj()
        (UIApplication.topViewController() as? FR_1)?.proceedInWorkflow(obj)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert((UIApplication.topViewController() as? FR2)?.data as? Obj === obj)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
    }

    func testNavWorkflowWhichSkipsAScreen_ButKeepsItInTheViewStack() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            static func instance() -> Self { Self() }
            func shouldLoad(with args: Any?) -> Bool { false }
        }
        class FR3: TestViewController { }

        let nav = UINavigationController()
        loadView(controller: nav)

        nav.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistance: .hiddenInitially)
                    .thenPresent(FR3.self), withLaunchStyle: .navigationStack)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        (UIApplication.topViewController()?.navigationController)?.popViewController(animated: false)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
    }

    func testNavWorkflowWhichSkipsAScreen_ButKeepsItInTheViewStack_BacksUp_ThenGoesForwardAgain() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            func shouldLoad(with args: Any?) -> Bool { false }

            static func instance() -> Self { Self() }
        }
        class FR3: TestViewController { }

        let nav = UINavigationController()
        loadView(controller: nav)

        nav.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistance: .hiddenInitially)
                    .thenPresent(FR3.self), withLaunchStyle: .navigationStack)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        (UIApplication.topViewController()?.navigationController)?.popViewController(animated: false)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
    }

    func testNavWorkflowWhichSkipsAScreen_ButKeepsItInTheViewStack_BacksUpUsingWorkflow_ThenGoesForwardAgain() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            func shouldLoad(with args: Any?) -> Bool { false }

            static func instance() -> Self { Self() }
        }
        class FR3: TestViewController { }

        let nav = UINavigationController()
        loadView(controller: nav)

        nav.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistance: .hiddenInitially)
                    .thenPresent(FR3.self), withLaunchStyle: .navigationStack)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        (UIApplication.topViewController() as? FR3)?.proceedBackwardInWorkflow()
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
    }

    func testNavWorkflowWhichSkipsFirstScreen_ButKeepsItInTheViewStack() {
        class FR1: TestViewController {
            override func shouldLoad(with args: AnyWorkflow.PassedArgs) -> Bool {
                _ = super.shouldLoad(with: args)
                return false
            }
        }
        class FR2: UIWorkflowItem<Never, Any?>, FlowRepresentable {
            static func instance() -> Self { Self() }
        }
        class FR3: TestViewController { }

        let nav = UINavigationController()
        loadView(controller: nav)

        nav.launchInto(Workflow(FR1.self, flowPersistance: .hiddenInitially)
                    .thenPresent(FR2.self)
                    .thenPresent(FR3.self), withLaunchStyle: .navigationStack)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        (UIApplication.topViewController()?.navigationController)?.popViewController(animated: false)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
    }

    func testNavWorkflowWhichSkipsFirstScreen_ButKeepsItInTheViewStack_BacksUp_ThenGoesForwardAgain() {
        class FR1: TestViewController {
            override func shouldLoad(with args: AnyWorkflow.PassedArgs) -> Bool {
                _ = super.shouldLoad(with: args)
                return false
            }
        }
        class FR2: UIWorkflowItem<Never, Any?>, FlowRepresentable {
            static func instance() -> Self { Self() }
        }
        class FR3: TestViewController { }

        let nav = UINavigationController()
        loadView(controller: nav)

        nav.launchInto(Workflow(FR1.self, flowPersistance: .hiddenInitially)
                    .thenPresent(FR2.self)
                    .thenPresent(FR3.self), withLaunchStyle: .navigationStack)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        (UIApplication.topViewController()?.navigationController)?.popViewController(animated: false)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
    }

    func testNavWorkflowWhichDoesNotSkipAScreen_ButRemovesItFromTheViewStack() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            func shouldLoad(with args: Any?) -> Bool { true }

            static func instance() -> Self { Self() }
        }
        class FR3: TestViewController { }

        let nav = UINavigationController()
        loadView(controller: nav)

        nav.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistance: .removedAfterProceeding)
                    .thenPresent(FR3.self), withLaunchStyle: .navigationStack)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        (UIApplication.topViewController()?.navigationController)?.popViewController(animated: false)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
    }

    func testNavWorkflowWhichDoesNotSkipFirstScreen_ButRemovesItFromTheViewStack() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Never, Any?>, FlowRepresentable {
            static func instance() -> Self { Self() }
        }
        class FR3: TestViewController { }

        let nav = UINavigationController()
        loadView(controller: nav)

        nav.launchInto(Workflow(FR1.self, flowPersistance: .removedAfterProceeding)
                    .thenPresent(FR2.self)
                    .thenPresent(FR3.self), withLaunchStyle: .navigationStack)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2, "Expected top view controller to be FR1 but was: \(UIApplication.topViewController())")
        XCTAssert(UIApplication.topViewController()?.navigationController?.viewControllers.first is FR2)
    }

    func testNavWorkflowWhichSkipsAScreen_ButKeepsItInTheViewStackUsingAClsure() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Never, Any?>, FlowRepresentable {
            static func instance() -> Self { Self() }
            func shouldLoad() -> Bool { false }
        }
        class FR3: TestViewController { }

        let nav = UINavigationController()
        loadView(controller: nav)

        nav.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistance: .hiddenInitially)
                    .thenPresent(FR3.self), withLaunchStyle: .navigationStack)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        (UIApplication.topViewController()?.navigationController)?.popViewController(animated: false)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
    }

    func testNavWorkflowWhichDoesNotSkipAScreen_ButRemovesItFromTheViewStackUsingAClsure() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Never, Any?>, FlowRepresentable {
            static func instance() -> Self { Self() }
        }
        class FR3: TestViewController { }

        let nav = UINavigationController()
        loadView(controller: nav)

        nav.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistance: .removedAfterProceeding)
                    .thenPresent(FR3.self), withLaunchStyle: .navigationStack)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        (UIApplication.topViewController()?.navigationController)?.popViewController(animated: false)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
    }

    func testNavWorkflowWhichSkipsAScreen_ButKeepsItInTheViewStackUsingAClsureWithData() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            static func instance() -> Self { Self() }
            func shouldLoad(with args: Any?) -> Bool { false }
        }
        class FR3: TestViewController { }

        let nav = UINavigationController()
        loadView(controller: nav)

        nav.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistance: { _ in .hiddenInitially })
                    .thenPresent(FR3.self), withLaunchStyle: .navigationStack)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow("blah")
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        (UIApplication.topViewController()?.navigationController)?.popViewController(animated: false)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
    }

    func testNavWorkflowWhichDoesNotSkipAScreen_ButRemovesItFromTheViewStackUsingAClsureWithData() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            func shouldLoad(with args: Any?) -> Bool {
                return true
            }
            static func instance() -> Self { Self() }
        }
        class FR3: TestViewController { }

        let nav = UINavigationController()
        loadView(controller: nav)

        nav.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistance: { data in
                        XCTAssertEqual(data as? String, "blah")
                        return .removedAfterProceeding
                    })
                    .thenPresent(FR3.self), withLaunchStyle: .navigationStack)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow("blah")
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        (UIApplication.topViewController()?.navigationController)?.popViewController(animated: false)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
    }

    func testModalWorkflowWhichSkipsAScreen_ButKeepsItInTheViewStack() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            static func instance() -> Self { Self() }
            func shouldLoad(with args: Any?) -> Bool { false }
        }
        class FR3: TestViewController { }

        let root = UIViewController()
        loadView(controller: root)

        root.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistance: .hiddenInitially)
                    .thenPresent(FR3.self), withLaunchStyle: .modal)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        UIApplication.topViewController()?.dismiss(animated: true)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
    }

    func testModalWorkflowWhichSkipsAScreen_andBacksUpWithWorkflow() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            static func instance() -> Self { Self() }
            func shouldLoad(with args: Any?) -> Bool { false }
        }
        class FR3: TestViewController { }

        let root = UIViewController()
        loadView(controller: root)

        root.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self)
                    .thenPresent(FR3.self), withLaunchStyle: .modal)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        (UIApplication.topViewController() as? FR3)?.proceedBackwardInWorkflow()
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
    }

    func testModalWorkflowWhichSkipsAScreen_ButKeepsItInTheViewStack_andBacksUpWithWorkflow() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            static func instance() -> Self { Self() }
            func shouldLoad(with args: Any?) -> Bool { false }
        }
        class FR3: TestViewController { }

        let root = UIViewController()
        loadView(controller: root)

        root.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistance: .hiddenInitially)
                    .thenPresent(FR3.self), withLaunchStyle: .modal)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        (UIApplication.topViewController() as? FR3)?.proceedBackwardInWorkflow()
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
    }

    func testModalWorkflowWhichSkipsFirstScreen_ButKeepsItInTheViewStack() {
        class FR1: TestViewController {
            override func shouldLoad(with args: AnyWorkflow.PassedArgs) -> Bool {
                _ = super.shouldLoad(with: args)
                return false
            }
        }
        class FR2: UIWorkflowItem<Never, Any?>, FlowRepresentable {
            static func instance() -> Self { Self() }
        }
        class FR3: TestViewController { }

        let root = UIViewController()
        loadView(controller: root)

        root.launchInto(Workflow(FR1.self, flowPersistance: .hiddenInitially)
                    .thenPresent(FR2.self)
                    .thenPresent(FR3.self), withLaunchStyle: .modal)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        UIApplication.topViewController()?.dismiss(animated: false)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
    }

    func testModalWorkflowWhichDoesNotSkipAScreen_ButRemovesItFromTheViewStack() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            static func instance() -> Self { Self() }
            func shouldLoad(with args: Any?) -> Bool { true }
        }
        class FR3: TestViewController { }

        let root = UIViewController()
        loadView(controller: root)

        root.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistance: .removedAfterProceeding)
                    .thenPresent(FR3.self), withLaunchStyle: .modal)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        UIApplication.topViewController()?.dismiss(animated: true)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
    }

    func testModalWorkflowWhichDoesNotSkipFirstScreen_ButRemovesItFromTheViewStack() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Never, Any?>, FlowRepresentable {
            static func instance() -> Self { Self() }
        }
        class FR3: TestViewController { }

        let root = UIViewController()
        loadView(controller: root)

        root.launchInto(Workflow(FR1.self, flowPersistance: .removedAfterProceeding)
                    .thenPresent(FR2.self)
                    .thenPresent(FR3.self), withLaunchStyle: .modal)

        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        UIApplication.topViewController()?.dismiss(animated: true)
        waitUntil(UIApplication.topViewController() === root)
        XCTAssert(UIApplication.topViewController() === root, "Expected top view controller to be root, but was: \(String(describing: UIApplication.topViewController()))")
    }

    func testModalWorkflowWhichSkipsAScreen_ButKeepsItInTheViewStackUsingAClosure() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Never, Any?>, FlowRepresentable {
            static func instance() -> Self { Self() }
            func shouldLoad() -> Bool { false }
        }
        class FR3: TestViewController { }

        let root = UIViewController()
        loadView(controller: root)

        root.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistance: .hiddenInitially)
                    .thenPresent(FR3.self), withLaunchStyle: .modal)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        UIApplication.topViewController()?.dismiss(animated: true)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
    }

    func testModalWorkflowWhichDoesNotSkipAScreen_ButRemovesItFromTheViewStackUsingAClsure() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Never, Any?>, FlowRepresentable {
            static func instance() -> Self { Self() }
        }
        class FR3: TestViewController { }

        let root = UIViewController()
        loadView(controller: root)

        root.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistance: .removedAfterProceeding)
                    .thenPresent(FR3.self), withLaunchStyle: .modal)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        UIApplication.topViewController()?.dismiss(animated: true)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
    }

    func testModalWorkflowWhichSkipsAScreen_ButKeepsItInTheViewStackUsingAClosureWithData() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            static func instance() -> Self { Self() }
            func shouldLoad(with args: Any?) -> Bool { false }
        }
        class FR3: TestViewController { }

        let root = UIViewController()
        loadView(controller: root)

        root.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistance: { _ in .hiddenInitially })
                    .thenPresent(FR3.self), withLaunchStyle: .modal)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow("blah")
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        UIApplication.topViewController()?.dismiss(animated: true)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
    }

    func testModalWorkflowWhichDoesNotSkipAScreen_ButRemovesItFromTheViewStackUsingAClosureWithData() {
        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Any?, Any?>, FlowRepresentable {
            func shouldLoad(with args: Any?) -> Bool {
                return true
            }
            static func instance() -> Self { Self() }
        }
        class FR3: TestViewController { }

        let root = UIViewController()
        loadView(controller: root)

        root.launchInto(Workflow(FR1.self)
                    .thenPresent(FR2.self, flowPersistance: { data in
                        XCTAssertEqual(data as? String, "blah")
                        return .removedAfterProceeding
                    })
                    .thenPresent(FR3.self), withLaunchStyle: .modal)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow("blah")
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        UIApplication.topViewController()?.dismiss(animated: true)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
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
        loadView(controller: nav)

        nav.launchInto(Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self))

        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        (UIApplication.topViewController() as? FR2)?.launchSecondary()
        waitUntil(UIApplication.topViewController() is FR_1)
        class Obj { }
        let obj = Obj()
        (UIApplication.topViewController() as? FR_1)?.proceedInWorkflow(obj)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert((UIApplication.topViewController() as? FR2)?.data as? Obj === obj)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
    }

    func testCallingThroughMultipleSkippedWorkflowItems() {
        class FR1: TestViewController {
            override func shouldLoad(with args: AnyWorkflow.PassedArgs) -> Bool {
                proceedInWorkflow(args.extract(nil))
                return false
            }
        }
        class FR2: TestViewController {
            override func shouldLoad(with args: AnyWorkflow.PassedArgs) -> Bool {
                proceedInWorkflow(args.extract(nil))
                return false
            }
        }
        class FR3: TestViewController {
            override func shouldLoad(with args: AnyWorkflow.PassedArgs) -> Bool {
                proceedInWorkflow(args.extract(nil))
                return false
            }
        }
        class FR4: TestViewController { }
        class Obj { }
        let obj = Obj()

        let root = UIViewController()
        let nav = UINavigationController(rootViewController: root)
        loadView(controller: nav)

        root.launchInto(Workflow(FR1.self)
            .thenPresent(FR2.self)
            .thenPresent(FR3.self)
            .thenPresent(FR4.self), args: obj)
        waitUntil(UIApplication.topViewController() is FR4)
        XCTAssert(UIApplication.topViewController() is FR4)
        XCTAssert((UIApplication.topViewController() as? FR4)?.data as? Obj === obj)
    }

    func testStartWithEmptyNav_LaunchWorkflowThatSkipsTheFirstScreenAndPassesData() {
        class FR1: TestViewController {
            override func shouldLoad(with args: AnyWorkflow.PassedArgs) -> Bool {
                proceedInWorkflow(args.extract(nil))
                return false
            }
        }
        class FR2: TestViewController { }
        class Obj { }
        let obj = Obj()

        let nav = UINavigationController()
        loadView(controller: nav)

        nav.launchInto(Workflow(FR1.self)
            .thenPresent(FR2.self), args: obj)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        XCTAssert((UIApplication.topViewController() as? FR2)?.data as? Obj === obj)
    }

    func testFinishingWorkflowCallsBack() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        class FR4: TestViewController { }

        let root = UIViewController()
        let nav = UINavigationController(rootViewController: root)
        loadView(controller: nav)

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

        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.next()
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        (UIApplication.topViewController() as? FR2)?.next()
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        (UIApplication.topViewController() as? FR3)?.next()
        waitUntil(UIApplication.topViewController() is FR4)
        XCTAssert(UIApplication.topViewController() is FR4)
        (UIApplication.topViewController() as? FR4)?.next()
        XCTAssert(callbackCalled)
    }

    func testFinishingWorkflowCallsBackEvenIfLastViewIsSkipped() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        class FR4: TestViewController {
            override func shouldLoad(with args: AnyWorkflow.PassedArgs) -> Bool {
                self.data = args
                return false
            }
        }

        let root = UIViewController()
        let nav = UINavigationController(rootViewController: root)
        loadView(controller: nav)

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
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        (UIApplication.topViewController() as? FR1)?.next()
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        (UIApplication.topViewController() as? FR2)?.next()
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        (UIApplication.topViewController() as? FR3)?.next()
        XCTAssert(callbackCalled)
    }

    static var viewDidLoadOnMockCalled = 0
    func testViewDidLoadGetsCalledWhereAppropriate() {
        UIKitPresenterTests.viewDidLoadOnMockCalled = 0

        class FR1: TestViewController { }
        class FR2: UIWorkflowItem<Never, Never>, FlowRepresentable {
            static func instance() -> Self { Self() }
        }

        let root = UIViewController()
        let nav = UINavigationController(rootViewController: root)
        loadView(controller: nav)

        root.launchInto(Workflow(FR1.self)
            .thenPresent(MockFlowRepresentable.self)
            .thenPresent(FR2.self))

        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)

        // Go forward to mock
        (UIApplication.topViewController() as? FR1)?.next()
        waitUntil(UIApplication.topViewController() is MockFlowRepresentable)
        XCTAssertEqual(UIKitPresenterTests.viewDidLoadOnMockCalled, 1)

        // Go to Final
        (UIApplication.topViewController() as? MockFlowRepresentable)?.proceedInWorkflow()
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        UIApplication.topViewController()?.navigationController?.popViewController(animated: false)

        // Go back to Mock
        waitUntil(UIApplication.topViewController() is MockFlowRepresentable)
        XCTAssertEqual(UIKitPresenterTests.viewDidLoadOnMockCalled, 1)

        // Go back to First
        UIApplication.topViewController()?.navigationController?.popViewController(animated: false)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)

        // Go forward to Mock
        (UIApplication.topViewController() as? FR1)?.next()

        waitUntil(UIApplication.topViewController() is MockFlowRepresentable)
        XCTAssertEqual(UIKitPresenterTests.viewDidLoadOnMockCalled, 2)
    }

    func testWorkflowLaunchModally() {
        class ExpectedModal: UIWorkflowItem<Never, Never>, FlowRepresentable {
            static func instance() -> Self {
                let modal = Self()
                modal.view.backgroundColor = .green
                return modal
            }
        }

        let rootController = UIViewController()
        let controller = UINavigationController(rootViewController: rootController)
        loadView(controller: controller)

        rootController.launchInto(Workflow(ExpectedModal.self), withLaunchStyle: .modal)

        RunLoop.current.singlePass()

        XCTAssertEqual(controller.viewControllers.count, 1)
        XCTAssert(rootController.mostRecentlyPresentedViewController is ExpectedModal, "mostRecentlyPresentedViewController should be ExpectedModal: \(String(describing: controller.mostRecentlyPresentedViewController))")
    }

    func testWorkflowLaunchModallyButSecondViewPreferrsANavController() {
        class ExpectedModal: UIWorkflowItem<Never, Never>, FlowRepresentable {
            static func instance() -> Self {
                let modal = Self()
                modal.view.backgroundColor = .green
                return modal
            }

            override func viewDidAppear(_ animated: Bool) {
                proceedInWorkflow()
            }
        }

        class ExpectedModalPreferNav: UIWorkflowItem<Never, Never>, FlowRepresentable {
            static func instance() -> Self {
                let modal = Self()
                modal.view.backgroundColor = .blue
                return modal
            }
        }

        let rootController = UIViewController()
        let controller = UINavigationController(rootViewController: rootController)
        loadView(controller: controller)

        rootController.launchInto(Workflow(ExpectedModal.self)
            .thenPresent(ExpectedModalPreferNav.self, presentationType: .navigationStack),
                                  withLaunchStyle: .modal)
        RunLoop.current.singlePass()

        XCTAssertEqual(controller.viewControllers.count, 1)
        XCTAssert(rootController.mostRecentlyPresentedViewController is ExpectedModal, "mostRecentlyPresentedViewController should be ExpectedModal: \(String(describing: controller.mostRecentlyPresentedViewController))")
        waitUntil(UIApplication.topViewController() is ExpectedModalPreferNav)
        XCTAssert(UIApplication.topViewController() is ExpectedModalPreferNav, "Top view controller should be ExpectedModalPresetNav:\(String(describing: UIApplication.topViewController()))")
        XCTAssertNotNil(UIApplication.topViewController()?.navigationController)
    }

    func testFluentWorkflowLaunchModallyButSecondViewPreferrsANavController() {
        class ExpectedModal: UIWorkflowItem<Never, Never>, FlowRepresentable {
            static func instance() -> Self {
                let modal = Self()
                modal.view.backgroundColor = .green
                return modal
            }

            override func viewDidAppear(_ animated: Bool) {
                proceedInWorkflow()
            }
        }

        class ExpectedModalPreferNav: UIWorkflowItem<Never, Never>, FlowRepresentable {
            static func instance() -> Self {
                let modal = Self()
                modal.view.backgroundColor = .blue
                return modal
            }
        }

        let rootController = UIViewController()
        let controller = UINavigationController(rootViewController: rootController)
        loadView(controller: controller)

        rootController.launchInto(
            Workflow(ExpectedModal.self)
                .thenPresent(ExpectedModalPreferNav.self,
                      presentationType: .navigationStack),
            withLaunchStyle: .modal)
        RunLoop.current.singlePass()

        XCTAssertEqual(controller.viewControllers.count, 1)
        XCTAssert(rootController.mostRecentlyPresentedViewController is ExpectedModal, "mostRecentlyPresentedViewController should be ExpectedModal: \(String(describing: controller.mostRecentlyPresentedViewController))")
        waitUntil(UIApplication.topViewController() is ExpectedModalPreferNav)
        XCTAssert(UIApplication.topViewController() is ExpectedModalPreferNav, "Top view controller should be ExpectedModalPresetNav:\(String(describing: UIApplication.topViewController()))")
        XCTAssertNotNil(UIApplication.topViewController()?.navigationController)
    }

    func testWorkflowLaunchModallyButFirstViewHasANavController() {
        class ExpectedModal: UIWorkflowItem<Never, Never>, FlowRepresentable {
            static func instance() -> Self {
                let modal = Self()
                modal.view.backgroundColor = .green
                return modal
            }
        }

        let firstView = UIViewController()
        let rootController = UIViewController()
        let controller = UINavigationController(rootViewController: rootController)
        loadView(controller: firstView)
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
            static func instance() -> Self {
                let modal = Self()
                modal.view.backgroundColor = .green
                return modal
            }
        }

        let firstView = UIViewController()
        let rootController = UIViewController()
        let controller = UINavigationController(rootViewController: rootController)
        loadView(controller: firstView)
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
        loadView(controller: controller)

        let workflow = Workflow(TestViewController.self)

        rootController.launchInto(workflow)

        waitUntil(UIApplication.topViewController() is TestViewController)

        workflow.abandon(animated: false, onFinish: testCallback)

        waitUntil(UIApplication.topViewController() === rootController)
        XCTAssert(UIApplication.topViewController() === rootController, "Expected top view to be 'rootController' but got: \(String(describing: UIApplication.topViewController()))")
        XCTAssertTrue(UIKitPresenterTests.testCallbackCalled)
    }

    func testWorkflowAbandonWhenLaunchedFromNavController_ExpectVCsToBeEmpty() {
        let controller = UINavigationController()
        loadView(controller: controller)

        let workflow = Workflow(TestViewController.self)

        controller.launchInto(workflow)

        waitUntil(UIApplication.topViewController() is TestViewController)

        workflow.abandon(animated: false, onFinish: testCallback)

        waitUntil(UIApplication.topViewController() === controller)
        XCTAssert(controller.viewControllers.isEmpty)
        XCTAssert(UIApplication.topViewController() === controller, "Expected top view to be 'controller' but got: \(String(describing: UIApplication.topViewController()))")
        XCTAssertTrue(UIKitPresenterTests.testCallbackCalled)
    }

    func testWorkflowAbandonWhenNoNavigationControllerExists() {
        let rootController = UIViewController()
        loadView(controller: rootController)

        let workflow = Workflow(TestViewController.self)

        rootController.launchInto(workflow)

        waitUntil(UIApplication.topViewController() is TestViewController)

        workflow.abandon(animated: false, onFinish: testCallback)

        waitUntil(UIApplication.topViewController() === rootController)
        XCTAssert(UIApplication.topViewController() === rootController, "Expected top view to be 'rootController' but got: \(String(describing: UIApplication.topViewController()))")
        XCTAssertTrue(UIKitPresenterTests.testCallbackCalled)
    }

    func testWorkflowAbandonWhenLaunchStyleIsNavigationStack() {
        let rootController = UIViewController()
        loadView(controller: rootController)

        let workflow = Workflow(TestViewController.self)

        rootController.launchInto(workflow, withLaunchStyle: .navigationStack)

        waitUntil(UIApplication.topViewController() is TestViewController)

        workflow.abandon(animated: false, onFinish: testCallback)

        waitUntil(UIApplication.topViewController() === rootController)
        XCTAssert(UIApplication.topViewController() === rootController, "Expected top view to be 'rootController' but got: \(String(describing: UIApplication.topViewController()))")
        XCTAssertTrue(UIKitPresenterTests.testCallbackCalled)
    }

    func testAbandonWhenWorkflowHasNavPresentingSubsequentViewsModally() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        class FR4: TestViewController { }

        let root = UIViewController()
        loadView(controller: root)

        root.launchInto(Workflow(FR1.self)
            .thenPresent(FR2.self, presentationType: .modal)
            .thenPresent(FR3.self)
            .thenPresent(FR4.self), withLaunchStyle: .navigationStack)

        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        XCTAssertNotNil(UIApplication.topViewController()?.navigationController)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        XCTAssertNil(UIApplication.topViewController()?.navigationController)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        (UIApplication.topViewController() as? FR3)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR4)
        XCTAssert(UIApplication.topViewController() is FR4)
        (UIApplication.topViewController() as? FR4)?.abandonWorkflow()
        waitUntil(UIApplication.topViewController() === root)
        XCTAssert(UIApplication.topViewController() === root)
    }

    func testAbandonWhenFluentWorkflowHasNavPresentingSubsequentViewsModally() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        class FR4: TestViewController { }

        let root = UIViewController()
        loadView(controller: root)

        root.launchInto(
            Workflow(FR1.self)
                .thenPresent(FR2.self, presentationType: .modal)
                .thenPresent(FR3.self)
                .thenPresent(FR4.self),
            withLaunchStyle: .navigationStack)
        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        XCTAssertNotNil(UIApplication.topViewController()?.navigationController)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        XCTAssertNil(UIApplication.topViewController()?.navigationController)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        (UIApplication.topViewController() as? FR3)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR4)
        XCTAssert(UIApplication.topViewController() is FR4)
        (UIApplication.topViewController() as? FR4)?.abandonWorkflow()
        waitUntil(UIApplication.topViewController() === root)
        XCTAssert(UIApplication.topViewController() === root)
    }

    func testAbandonWhenWorkflowHasNavPresentingSubsequentViewsModallyAndWithMoreNavigation() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        class FR4: TestViewController { }

        let root = UIViewController()
        loadView(controller: root)
        root.launchInto(Workflow(FR1.self)
            .thenPresent(FR2.self, presentationType: .modal)
            .thenPresent(FR3.self, presentationType: .navigationStack)
            .thenPresent(FR4.self, presentationType: .modal),
                        withLaunchStyle: .navigationStack)

        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        XCTAssertNotNil(UIApplication.topViewController()?.navigationController)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        XCTAssertNil(UIApplication.topViewController()?.navigationController)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        (UIApplication.topViewController() as? FR3)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR4)
        XCTAssert(UIApplication.topViewController() is FR4)
        (UIApplication.topViewController() as? FR4)?.abandonWorkflow()
        waitUntil(UIApplication.topViewController() === root)
        XCTAssert(UIApplication.topViewController() === root)
    }

    func testAbandonWhenFluentWorkflowHasNavPresentingSubsequentViewsModallyAndWithMoreNavigation() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        class FR4: TestViewController { }

        let root = UIViewController()
        loadView(controller: root)

        root.launchInto(
            Workflow(FR1.self)
                .thenPresent(FR2.self, presentationType: .modal)
                .thenPresent(FR3.self, presentationType: .navigationStack)
                .thenPresent(FR4.self, presentationType: .modal),
            withLaunchStyle: .navigationStack)

        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        XCTAssertNotNil(UIApplication.topViewController()?.navigationController)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        XCTAssertNil(UIApplication.topViewController()?.navigationController)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        (UIApplication.topViewController() as? FR3)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR4)
        XCTAssert(UIApplication.topViewController() is FR4)
        (UIApplication.topViewController() as? FR4)?.abandonWorkflow()
        waitUntil(UIApplication.topViewController() === root)
        XCTAssert(UIApplication.topViewController() === root)
    }

    func testAbandonWhenWorkflowHasNavWithStartingViewPresentingSubsequentViewsModallyAndWithMoreNavigation() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        class FR4: TestViewController { }

        let root = UIViewController()
        let nav = UINavigationController(rootViewController: root)
        loadView(controller: nav)

        root.launchInto(Workflow(FR1.self)
            .thenPresent(FR2.self, presentationType: .modal)
            .thenPresent(FR3.self, presentationType: .navigationStack)
            .thenPresent(FR4.self, presentationType: .modal),
                        withLaunchStyle: .navigationStack)

        waitUntil(UIApplication.topViewController() is FR1)
        XCTAssert(UIApplication.topViewController() is FR1)
        XCTAssertNotNil(UIApplication.topViewController()?.navigationController)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR2)
        XCTAssert(UIApplication.topViewController() is FR2)
        XCTAssertNil(UIApplication.topViewController()?.navigationController)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR3)
        XCTAssert(UIApplication.topViewController() is FR3)
        (UIApplication.topViewController() as? FR3)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is FR4)
        XCTAssert(UIApplication.topViewController() is FR4)
        (UIApplication.topViewController() as? FR4)?.abandonWorkflow()
        waitUntil(UIApplication.topViewController() === root)
        XCTAssert(UIApplication.topViewController() === root)
    }

    func testWorkflowLaunchModallyButFirstViewHasANavControllerAndThenDismiss() {
        class ExpectedModal: UIWorkflowItem<Never, Never>, FlowRepresentable {
            static func instance() -> Self {
                let modal = Self()
                modal.view.backgroundColor = .green
                return modal
            }
        }
        let rootController = UIViewController()
        let controller = UINavigationController(rootViewController: rootController)
        loadView(controller: controller)

        let workflow = Workflow(TestViewController.self)
            .thenPresent(ExpectedModal.self, presentationType: .modal)

        rootController.launchInto(workflow)

        waitUntil(UIApplication.topViewController() is TestViewController)
        (UIApplication.topViewController() as? TestViewController)?.proceedInWorkflow(nil)
        waitUntil(UIApplication.topViewController() is ExpectedModal)

        workflow.abandon(animated: false, onFinish: testCallback)

        waitUntil(UIApplication.topViewController() === rootController)
        XCTAssert(UIApplication.topViewController() === rootController, "Expected top view to be 'rootController' but got: \(String(describing: UIApplication.topViewController()))")
        XCTAssertTrue(UIKitPresenterTests.testCallbackCalled)
    }

    func testWorkflowLaunchWithNavigationStack() {
        class ExpectedController: UIWorkflowItem<Never, Never>, FlowRepresentable {
            static func instance() -> Self {
                let controller = Self()
                controller.view.backgroundColor = .green
                return controller
            }
        }

        let rootController = UIViewController()
        let controller = UINavigationController(rootViewController: rootController)
        loadView(controller: controller)

        rootController.launchInto(Workflow(ExpectedController.self), withLaunchStyle: .navigationStack)
        RunLoop.current.singlePass()

        XCTAssertEqual(controller.viewControllers.count, 2)
        XCTAssertFalse(rootController.mostRecentlyPresentedViewController is ExpectedController, "mostRecentlyPresentedViewController should not be ExpectedModal: \(String(describing: controller.mostRecentlyPresentedViewController))")
    }

    func testWorkflowLaunchWithNavigationStackWhenLauncherDoesNotHavNavController() {
        class ExpectedController: UIWorkflowItem<Never, Never>, FlowRepresentable {
            static func instance() -> Self {
                let controller = Self()
                controller.view.backgroundColor = .green
                return controller
            }
        }

        let rootController = UIViewController()
        loadView(controller: rootController)

        rootController.launchInto(Workflow(ExpectedController.self), withLaunchStyle: .navigationStack)
        RunLoop.current.singlePass()

        XCTAssert(rootController.mostRecentlyPresentedViewController is UINavigationController, "mostRecentlyPresentedViewController should be nav controller: \(String(describing: rootController.mostRecentlyPresentedViewController))")
        XCTAssertEqual((rootController.mostRecentlyPresentedViewController as? UINavigationController)?.viewControllers.count, 1)
        XCTAssert((rootController.mostRecentlyPresentedViewController as? UINavigationController)?.viewControllers.first is ExpectedController)
    }

    func testWorkflowLaunchesWithNavButHasAViewThatPreferrsModalBecauseItCan() {
        class ExpectedModal: UIWorkflowItem<Never, Never>, FlowRepresentable {
            static func instance() -> Self {
                let modal = Self()
                modal.view.backgroundColor = .green
                return modal
            }
        }
        class ExpectedNav: UIWorkflowItem<Never, Never>, FlowRepresentable {
            static func instance() -> Self {
                let modal = Self()
                modal.view.backgroundColor = .blue
                return modal
            }
        }
        let rootController = UIViewController()
        let controller = UINavigationController(rootViewController: rootController)
        loadView(controller: controller)

        rootController.launchInto(Workflow(ExpectedNav.self)
            .thenPresent(ExpectedModal.self, presentationType: .modal))

        waitUntil(UIApplication.topViewController() is ExpectedNav)
        XCTAssertEqual(controller.viewControllers.count, 2)
        (UIApplication.topViewController() as? ExpectedNav)?.proceedInWorkflow()
        waitUntil(UIApplication.topViewController() is ExpectedModal)
        XCTAssert(UIApplication.topViewController() is ExpectedModal, "Top View was not a modal")
        XCTAssertNil((UIApplication.topViewController() as? ExpectedModal)?.navigationController, "You didn't present modally")
    }

    func testFlowRepresentableThatDoesNotTakeInData() {
        class ExpectedController: UIWorkflowItem<Never, Never>, FlowRepresentable {
            static func instance() -> Self {
                let controller = Self()
                controller.view.backgroundColor = .green
                return controller
            }
        }

        let rootController = UIViewController()
        loadView(controller: rootController)

        rootController.launchInto(Workflow(ExpectedController.self), withLaunchStyle: .navigationStack)
        RunLoop.current.singlePass()

        XCTAssert(rootController.mostRecentlyPresentedViewController is UINavigationController, "mostRecentlyPresentedViewController should be nav controller: \(String(describing: rootController.mostRecentlyPresentedViewController))")
        XCTAssertEqual((rootController.mostRecentlyPresentedViewController as? UINavigationController)?.viewControllers.count, 1)
        XCTAssert((rootController.mostRecentlyPresentedViewController as? UINavigationController)?.viewControllers.first is ExpectedController)
    }

    func testFlowRepresentableThatDoesNotTakeInDataAndOverridesShouldLoad() {
        class ExpectedController: UIWorkflowItem<Never, Never>, FlowRepresentable {
            static func instance() -> Self {
                let controller = Self()
                controller.view.backgroundColor = .green
                return controller
            }
            func shouldLoad() -> Bool { false }
        }

        let rootController = UIViewController()
        loadView(controller: rootController)

        rootController.launchInto(Workflow(ExpectedController.self))

        RunLoop.current.singlePass()

        XCTAssert(UIApplication.topViewController() === rootController)
    }

    func testUnknownLaunchStyleThrowsFatalError() {
        let ls = LaunchStyle.new
        class FR1: TestViewController { }
        class FR2: TestViewController { }

        let wf = Workflow(FR1.self).thenPresent(FR2.self)
        let rootController = UIViewController()
        loadView(controller: rootController)

        let presenter = UIKitPresenter(rootController, launchStyle: .modal)

        wf.applyOrchestrationResponder(presenter)
        var fr1 = FR1()
        let node = AnyWorkflow.InstanceNode(with: AnyFlowRepresentable(&fr1))
        let metadata = FlowRepresentableMetaData(FR1.self, launchStyle: ls, flowPersistance: { _ in .default })

        XCTAssertThrowsFatalError {
            presenter.proceed(to: (instance: node, metadata: metadata),
                              from: (instance: node, metadata: metadata))
        }
    }
}

extension UIKitPresenterTests {
    class TestViewController: UIWorkflowItem<AnyWorkflow.PassedArgs, Any?>, FlowRepresentable {
        var data: Any?
        static func instance() -> Self {
            let controller = Self()
            controller.view.backgroundColor = .red
            return controller
        }
        func shouldLoad(with args: AnyWorkflow.PassedArgs) -> Bool {
            self.data = args.extract(nil)
            return true
        }
        func next() {
            proceedInWorkflow(data)
        }
    }
}

class MockFlowRepresentable: UIWorkflowItem<Never, Never>, FlowRepresentable {
    static func instance() -> Self { Self() }

    func shouldLoad() -> Bool { true }

    override func viewDidLoad() {
        UIKitPresenterTests.viewDidLoadOnMockCalled += 1
    }
}
