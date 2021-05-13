//
//  UIKitConsumerWorkflowChainingTests.swift
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

class UIKitConsumerWorkflowChainingTests: XCTestCase {
    override func setUpWithError() throws {
        UIView.setAnimationsEnabled(false)
        UIViewController.initializeTestable()
    }

    override func tearDownWithError() throws {
        UIViewController.flushPendingTestArtifacts()
        UIView.setAnimationsEnabled(true)
    }

    func testWorkflowLaunchingWorkflow() {
        class FR1: TestViewController { }
        class FR2: TestViewController {
            func launchSecondary() {
                let wf = Workflow(FR_1.self)
                launchInto(wf) { args in
                    self.data = args.extractArgs(defaultValue: nil)
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
                    self.data = args.extractArgs(defaultValue: nil)
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
                    self.data = args.extractArgs(defaultValue: nil)
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

    func testNavWorkflowLaunchingNewWorkflowWithNavigationStack_Abandoning_ThenProceedingInNav() {
        class FR1: TestViewController { }
        class FR2: TestViewController {
            func launchSecondary() {
                let wf = Workflow(FR_1.self)
                launchInto(wf, withLaunchStyle: .navigationStack) { args in
                    self.data = args.extractArgs(defaultValue: nil)
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

}

extension UIKitConsumerWorkflowChainingTests {
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
