//
//  UIKitConsumerSkipTests.swift
//  WorkflowUIKitTests
//
//  Created by Richard Gist on 5/12/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
import UIUTest

// Do *not* change to @testable import, we want tests driven from the consumer standpoint
import Workflow
import WorkflowUIKit

class UIKitConsumerSkipTests: XCTestCase {
    override func setUpWithError() throws {
        UIView.setAnimationsEnabled(false)
        UIViewController.initializeTestable()
    }

    override func tearDownWithError() throws {
        UIViewController.flushPendingTestArtifacts()
        UIView.setAnimationsEnabled(true)
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
            XCTAssert(args.extractArgs(defaultValue: nil) as? Obj === obj)
        }
        XCTAssertUIViewControllerDisplayed(ofType: FR1.self)
        (UIApplication.topViewController() as? FR1)?.next()
        XCTAssertUIViewControllerDisplayed(ofType: FR2.self)
        (UIApplication.topViewController() as? FR2)?.next()
        XCTAssertUIViewControllerDisplayed(ofType: FR3.self)
        (UIApplication.topViewController() as? FR3)?.next()
        XCTAssert(callbackCalled)
    }

}

extension UIKitConsumerSkipTests {
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
