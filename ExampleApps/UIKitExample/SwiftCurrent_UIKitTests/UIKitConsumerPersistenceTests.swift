//
//  UIKitConsumerPersistenceTests.swift
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

class UIKitConsumerPersistenceTests: XCTestCase {
    override func setUpWithError() throws {
        UIView.setAnimationsEnabled(false)
        UIViewController.initializeTestable()
    }

    override func tearDownWithError() throws {
        UIViewController.flushPendingTestArtifacts()
        UIView.setAnimationsEnabled(true)
    }

    func testHiddenInitiallyAndPersistWhenSkippedAreTheSame() {
        XCTAssertEqual(FlowPersistence.hiddenInitially, .persistWhenSkipped)
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
                        .thenProceed(with: FR2.self, flowPersistence: .removedAfterProceeding)
                        .thenProceed(with: FR3.self), withLaunchStyle: .navigationStack)
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
                        .thenProceed(with: FR2.self)
                        .thenProceed(with: FR3.self), withLaunchStyle: .navigationStack)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        XCTAssert(UIApplication.topViewController()?.navigationController?.viewControllers.first is FR2)
    }

    func testNavWorkflowWhichDoesNotSkipAScreen_ButRemovesItFromTheViewStackUsingAClosure() {
        class FR1: TestViewController { }
        final class FR2: UIWorkflowItem<Never, Any?>, FlowRepresentable { }
        class FR3: TestViewController { }

        let nav = UINavigationController()
        nav.loadForTesting()

        nav.launchInto(Workflow(FR1.self)
                        .thenProceed(with: FR2.self, flowPersistence: .removedAfterProceeding)
                        .thenProceed(with: FR3.self), withLaunchStyle: .navigationStack)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController()?.navigationController)?.popViewController(animated: false)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
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
                        .thenProceed(with: FR2.self, flowPersistence: { data in
                            XCTAssertEqual(data as? String, "blah")
                            return .removedAfterProceeding
                        })
                        .thenProceed(with: FR3.self), withLaunchStyle: .navigationStack)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow("blah")
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController()?.navigationController)?.popViewController(animated: false)
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
                            .thenProceed(with: FR2.self, flowPersistence: .removedAfterProceeding)
                            .thenProceed(with: FR3.self), withLaunchStyle: .modal)
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
                            .thenProceed(with: FR2.self)
                            .thenProceed(with: FR3.self), withLaunchStyle: .modal)

        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        UIApplication.topViewController()?.dismiss(animated: true)
        XCTAssertUIViewControllerDisplayed(isInstance: root)
    }

    func testModalWorkflowWhichDoesNotSkipAScreen_ButRemovesItFromTheViewStackUsingAClsure() {
        class FR1: TestViewController { }
        final class FR2: UIWorkflowItem<Never, Any?>, FlowRepresentable { }
        class FR3: TestViewController { }

        let root = UIViewController()
        root.loadForTesting()

        root.launchInto(Workflow(FR1.self)
                            .thenProceed(with: FR2.self, flowPersistence: .removedAfterProceeding)
                            .thenProceed(with: FR3.self), withLaunchStyle: .modal)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        UIApplication.topViewController()?.dismiss(animated: true)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
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
                            .thenProceed(with: FR2.self, flowPersistence: { data in
                                XCTAssertEqual(data as? String, "blah")
                                return .removedAfterProceeding
                            })
                            .thenProceed(with: FR3.self), withLaunchStyle: .modal)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow("blah")
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        UIApplication.topViewController()?.dismiss(animated: true)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
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
                        .thenProceed(with: FR2.self, flowPersistence: .hiddenInitially)
                        .thenProceed(with: FR3.self), withLaunchStyle: .navigationStack)
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
                        .thenProceed(with: FR2.self, flowPersistence: .hiddenInitially)
                        .thenProceed(with: FR3.self), withLaunchStyle: .navigationStack)
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
                        .thenProceed(with: FR2.self, flowPersistence: .hiddenInitially)
                        .thenProceed(with: FR3.self), withLaunchStyle: .navigationStack)
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
                        .thenProceed(with: FR2.self)
                        .thenProceed(with: FR3.self), withLaunchStyle: .navigationStack)
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
                        .thenProceed(with: FR2.self)
                        .thenProceed(with: FR3.self), withLaunchStyle: .navigationStack)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController()?.navigationController)?.popViewController(animated: false)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
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
                        .thenProceed(with: FR2.self, flowPersistence: .hiddenInitially)
                        .thenProceed(with: FR3.self), withLaunchStyle: .navigationStack)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController()?.navigationController)?.popViewController(animated: false)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
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
                        .thenProceed(with: FR2.self, flowPersistence: { _ in .hiddenInitially })
                        .thenProceed(with: FR3.self), withLaunchStyle: .navigationStack)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow("blah")
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController()?.navigationController)?.popViewController(animated: false)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
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
                            .thenProceed(with: FR2.self, flowPersistence: .hiddenInitially)
                            .thenProceed(with: FR3.self), withLaunchStyle: .modal)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        UIApplication.topViewController()?.dismiss(animated: true)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
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
                            .thenProceed(with: FR2.self, flowPersistence: .hiddenInitially)
                            .thenProceed(with: FR3.self), withLaunchStyle: .modal)
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
        final class FR2: UIWorkflowItem<Never, Any?>, FlowRepresentable { }
        class FR3: TestViewController { }

        let root = UIViewController()
        root.loadForTesting()

        root.launchInto(Workflow(FR1.self, flowPersistence: .hiddenInitially)
                            .thenProceed(with: FR2.self)
                            .thenProceed(with: FR3.self), withLaunchStyle: .modal)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        UIApplication.topViewController()?.dismiss(animated: false)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
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
                            .thenProceed(with: FR2.self, flowPersistence: .hiddenInitially)
                            .thenProceed(with: FR3.self), withLaunchStyle: .modal)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        UIApplication.topViewController()?.dismiss(animated: true)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
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
                            .thenProceed(with: FR2.self, flowPersistence: { _ in .hiddenInitially })
                            .thenProceed(with: FR3.self), withLaunchStyle: .modal)
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow("blah")
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        UIApplication.topViewController()?.dismiss(animated: true)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
    }

    func testDefaultWorkflow_LaunchedFromModal_CanDestroyAllItems_AndStillProceedThroughFlow_AndCallOnFinish() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        let root = UIViewController()
        root.loadForTesting()

        let expectOnFinish = self.expectation(description: "onFinish called")
        root.launchInto(Workflow(FR1.self, flowPersistence: .removedAfterProceeding)
                            .thenProceed(with: FR2.self, flowPersistence: .removedAfterProceeding)
                            .thenProceed(with: FR3.self, flowPersistence: .removedAfterProceeding)) { _ in
            XCTAssertUIViewControllerDisplayed(isInstance: root)
            XCTAssertNil(UIApplication.topViewController()?.presentingViewController)
            expectOnFinish.fulfill()
        }
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        XCTAssert(UIApplication.topViewController()?.presentingViewController === root)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        XCTAssert(UIApplication.topViewController()?.presentingViewController === root)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController() as? FR3)?.proceedInWorkflow(nil)

        wait(for: [expectOnFinish], timeout: 3)
    }

    func testDefaultWorkflow_LaunchedFromNav_CanDestroyAllItems_AndStillProceedThroughFlow_AndCallOnFinish() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        let root = UIViewController()
        let navigationController = UINavigationController(rootViewController: root)
        navigationController.loadForTesting()

        let expectOnFinish = self.expectation(description: "onFinish called")
        root.launchInto(Workflow(FR1.self, flowPersistence: .removedAfterProceeding)
                            .thenProceed(with: FR2.self, flowPersistence: .removedAfterProceeding)
                            .thenProceed(with: FR3.self, flowPersistence: .removedAfterProceeding)) { _ in
            XCTAssertUIViewControllerDisplayed(isInstance: root)
            XCTAssertEqual(UIApplication.topViewController()?.navigationController?.viewControllers.count, 1)
            expectOnFinish.fulfill()
        }
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        XCTAssert(UIApplication.topViewController()?.navigationController?.viewControllers.first === root,
                  "\(String(describing: UIApplication.topViewController()?.navigationController?.viewControllers.first)) was not \(root)")
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        XCTAssert(UIApplication.topViewController()?.navigationController?.viewControllers.first === root,
                  "\(String(describing: UIApplication.topViewController()?.navigationController?.viewControllers.first)) was not \(root)")
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController() as? FR3)?.proceedInWorkflow(nil)

        wait(for: [expectOnFinish], timeout: 3)
    }
    
    func testDefaultWorkflow_LaunchedFromNav_CanDestroyAllItems_WhenLastFRIsNotLoaded() {
        class FR1: TestViewController { }
        class FR2: TestViewController { override func shouldLoad() -> Bool { false } }
        class FR3: TestViewController { override func shouldLoad() -> Bool { false } }

        let root = UIViewController()
        let navigationController = UINavigationController(rootViewController: root)
        navigationController.loadForTesting()
        let expectOnFinish = self.expectation(description: "onFinish called")
        
        root.launchInto(Workflow(FR1.self, flowPersistence: .removedAfterProceeding)
                            .thenProceed(with: FR2.self, flowPersistence: .removedAfterProceeding)
                            .thenProceed(with: FR3.self, flowPersistence: .removedAfterProceeding)) { _ in
            XCTAssertUIViewControllerDisplayed(isInstance: root)
            XCTAssertEqual(UIApplication.topViewController()?.navigationController?.viewControllers.count, 1)
            expectOnFinish.fulfill()
        }
        
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        XCTAssert(UIApplication.topViewController()?.navigationController?.viewControllers.first === root,
                  "\(String(describing: UIApplication.topViewController()?.navigationController?.viewControllers.first)) was not \(root)")
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssert(UIApplication.topViewController()?.navigationController?.viewControllers.first === root,
                  "\(String(describing: UIApplication.topViewController()?.navigationController?.viewControllers.first)) was not \(root)")

        wait(for: [expectOnFinish], timeout: 3)
    }

    func testModalWorkflow_LaunchedFromNav_CanDestroyAllItems_AndStillProceedThroughFlow_AndCallOnFinish() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        let root = UIViewController()
        let nav = UINavigationController(rootViewController: root)
        nav.loadForTesting()

        let expectOnFinish = self.expectation(description: "onFinish called")
        root.launchInto(Workflow(FR1.self, flowPersistence: .removedAfterProceeding)
                            .thenProceed(with: FR2.self, flowPersistence: .removedAfterProceeding)
                            .thenProceed(with: FR3.self, flowPersistence: .removedAfterProceeding),
                        withLaunchStyle: .modal) { _ in
            XCTAssertUIViewControllerDisplayed(isInstance: root)
            XCTAssertNil(UIApplication.topViewController()?.presentingViewController)
            expectOnFinish.fulfill()
        }
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        XCTAssert(UIApplication.topViewController()?.presentingViewController === nav,
                  "\(String(describing: UIApplication.topViewController()?.presentingViewController)) was not \(nav)")
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        XCTAssert(UIApplication.topViewController()?.presentingViewController === nav,
                  "\(String(describing: UIApplication.topViewController()?.presentingViewController)) was not \(nav)")
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController() as? FR3)?.proceedInWorkflow(nil)

        wait(for: [expectOnFinish], timeout: 3)
    }

    func testModalWorkflow_CanPresentNewViewControllerModally_AndCallOnFinish() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController {
            let presented = UIViewController()
            func presentOutsideViewController() {
                present(presented, animated: false)
            }
        }
        var presented: UIViewController?
        let root = UIViewController()
        let nav = UINavigationController(rootViewController: root)
        nav.loadForTesting()

        let expectOnFinish = self.expectation(description: "onFinish called")
        root.launchInto(Workflow(FR1.self, flowPersistence: .removedAfterProceeding)
                            .thenProceed(with: FR2.self, flowPersistence: .removedAfterProceeding)
                            .thenProceed(with: FR3.self, flowPersistence: .removedAfterProceeding),
                        withLaunchStyle: .modal) { _ in
            XCTAssertNotNil(presented)
            if let presented = presented {
                XCTAssertUIViewControllerDisplayed(isInstance: presented)
            }
            XCTAssertEqual(UIApplication.topViewController()?.presentingViewController, nav)
            expectOnFinish.fulfill()
        }
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        XCTAssert(UIApplication.topViewController()?.presentingViewController === nav,
                  "\(String(describing: UIApplication.topViewController()?.presentingViewController)) was not \(nav)")
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        XCTAssert(UIApplication.topViewController()?.presentingViewController === nav,
                  "\(String(describing: UIApplication.topViewController()?.presentingViewController)) was not \(nav)")
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)

        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)

        let fr3 = (UIApplication.topViewController() as? FR3)
        presented = fr3?.presented
        fr3?.presentOutsideViewController()
        fr3?.proceedInWorkflow(nil)

        wait(for: [expectOnFinish], timeout: 3)
    }

    func testNavWorkflow_LaunchedFromModal_CanDestroyAllItems_AndStillProceedThroughFlow_AndCallOnFinish() {
        class FR1: TestViewController { }
        class FR2: TestViewController { }
        class FR3: TestViewController { }
        let root = UIViewController()
        root.loadForTesting()

        let expectOnFinish = self.expectation(description: "onFinish called")
        root.launchInto(Workflow(FR1.self, flowPersistence: .removedAfterProceeding)
                            .thenProceed(with: FR2.self, flowPersistence: .removedAfterProceeding)
                            .thenProceed(with: FR3.self, flowPersistence: .removedAfterProceeding),
                        withLaunchStyle: .navigationStack) { _ in
            XCTAssertUIViewControllerDisplayed(isInstance: root)
            XCTAssertNil(UIApplication.topViewController()?.presentingViewController)
            expectOnFinish.fulfill()
        }
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        XCTAssert(UIApplication.topViewController()?.presentingViewController === root)
        (UIApplication.topViewController() as? FR1)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        XCTAssert(UIApplication.topViewController()?.presentingViewController === root)
        (UIApplication.topViewController() as? FR2)?.proceedInWorkflow(nil)
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController() as? FR3)?.proceedInWorkflow(nil)

        wait(for: [expectOnFinish], timeout: 3)
    }
}

extension UIKitConsumerPersistenceTests {
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
