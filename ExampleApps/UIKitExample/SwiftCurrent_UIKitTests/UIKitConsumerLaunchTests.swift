//
//  UIKitConsumerLaunchTests.swift
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

class UIKitConsumerLaunchTests: XCTestCase {
    static var testCallbackCalled = false
    let testCallback = {
        UIKitConsumerLaunchTests.testCallbackCalled = true
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

    func testWorkflowCanLaunchViewController() {
        class FR1: UIViewController, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?
        }
        let flow = Workflow(FR1.self)

        let root = UIViewController()
        root.loadForTesting()
        root.launchInto(flow)

        XCTAssert(UIApplication.topViewController() is FR1)
    }

    func testWorkflowCanPushOntoExistingNavController() {
        class FR1: UIViewController, FlowRepresentable {
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

        nav.launchInto(Workflow(FR1.self, launchStyle: .navigationStack), withLaunchStyle: .navigationStack)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        XCTAssertNil(nav.mostRecentlyPresentedViewController)
        XCTAssertNotNil(UIApplication.topViewController()?.navigationController)
        XCTAssert(UIApplication.topViewController()?.navigationController === nav)
        XCTAssertEqual(UIApplication.topViewController()?.navigationController?.viewControllers.count, 1)
        XCTAssert(UIApplication.topViewController()?.navigationController?.visibleViewController is FR1)
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
                                    .thenProceed(with: ExpectedModalPreferNav.self, launchStyle: .navigationStack),
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
                .thenProceed(with: ExpectedModalPreferNav.self,
                             launchStyle: .navigationStack),
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

        let workflow = Workflow(ExpectedModal.self, launchStyle: .navigationStack)

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

        let workflow = Workflow(ExpectedNav.self, launchStyle: .navigationStack)
        rootController.launchInto(workflow, withLaunchStyle: .modal)
        RunLoop.current.singlePass()

        XCTAssertEqual(controller.viewControllers.count, 1)
        XCTAssert(rootController.mostRecentlyPresentedViewController is UINavigationController, "mostRecentlyPresentedViewController should be UINavigationController: \(String(describing: rootController.mostRecentlyPresentedViewController))")
        XCTAssertEqual((rootController.mostRecentlyPresentedViewController as? UINavigationController)?.viewControllers.count, 1)
        XCTAssert((rootController.mostRecentlyPresentedViewController as? UINavigationController)?.viewControllers.first is ExpectedNav, "rootViewController should be ExpectedNav: \(String(describing: (rootController.mostRecentlyPresentedViewController as? UINavigationController)?.viewControllers.first))")
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
            .thenProceed(with: ExpectedModal.self, launchStyle: .modal)

        rootController.launchInto(workflow)

        XCTAssertUIViewControllerDisplayed(ofType: TestViewController.self)
        (UIApplication.topViewController() as? TestViewController)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: ExpectedModal.self)

        workflow.abandon(animated: false, onFinish: testCallback)

        XCTAssertUIViewControllerDisplayed(isInstance: rootController)
        XCTAssertTrue(Self.testCallbackCalled)
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
                                    .thenProceed(with: ExpectedModal.self, launchStyle: .modal))

        XCTAssertUIViewControllerDisplayed(ofType: ExpectedNav.self)
        XCTAssertEqual(controller.viewControllers.count, 2)
        (UIApplication.topViewController() as? ExpectedNav)?.proceedInWorkflow()
        XCTAssertUIViewControllerDisplayed(ofType: ExpectedModal.self)
        XCTAssertNil((UIApplication.topViewController() as? ExpectedModal)?.navigationController, "You didn't present modally")
    }

    func testKnownPresentationTypes_CanBeDecoded() throws {
        final class TestView: UIViewController, FlowRepresentable, WorkflowDecodable {
            weak var _workflowPointer: AnyFlowRepresentable?
        }
        let validLaunchStyles: [String: LaunchStyle] = [
            "automatic": .default,
            "navigationStack": .PresentationType.navigationStack.rawValue,
            "modal": .PresentationType.modal.rawValue,
            "modal(.automatic)": .PresentationType.modal(.automatic).rawValue,
            "modal(.currentContext)": .PresentationType.modal(.currentContext).rawValue,
            "modal(.custom)": .PresentationType.modal(.custom).rawValue,
            "modal(.formSheet)": .PresentationType.modal(.formSheet).rawValue,
            "modal(.fullScreen)": .PresentationType.modal(.fullScreen).rawValue,
            "modal(.overCurrentContext)": .PresentationType.modal(.overCurrentContext).rawValue,
            "modal(.overFullScreen)": .PresentationType.modal(.overFullScreen).rawValue,
            "modal(.popover)": .PresentationType.modal(.popover).rawValue,
            "modal(.pageSheet)": .PresentationType.modal(.pageSheet).rawValue,
        ]

        let WD: WorkflowDecodable.Type = TestView.self

        try validLaunchStyles.forEach { (key, value) in
            XCTAssertIdentical(try TestView.decodeLaunchStyle(named: key), value)
            XCTAssertIdentical(try WD.decodeLaunchStyle(named: key), value)
        }

        // Metatest, testing we covered all styles
        LaunchStyle.PresentationType.allCases.forEach { presentationType in
            XCTAssert(validLaunchStyles.values.contains { $0 === presentationType.rawValue }, "dictionary of validLaunchStyles did not contain one for \(presentationType)")
        }
    }
}

extension UIKitConsumerLaunchTests {
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
