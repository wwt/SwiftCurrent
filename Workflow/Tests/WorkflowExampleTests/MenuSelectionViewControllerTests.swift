//
//  MenuSelectionViewControllerTests.swift
//  WorkflowExampleTests
//
//  Created by Tyler Thompson on 10/5/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import WorkflowExample

class MenuSelectionViewControllerTests: ViewControllerTest<MenuSelectionViewController> {
    func testShouldLoadIfThereAreMultipleMenuTypes() {
        let locationWithNone = Location(name: "", address: Address(), orderTypes: [], menuTypes: [])
        let locationWithMultiple = Location(name: "", address: Address(), orderTypes: [], menuTypes: [.regular, .catering])

        loadFromStoryboard(args: .args(Order(location: locationWithNone)))
        XCTAssertFalse(testViewController.shouldLoad())

        loadFromStoryboard(args: .args(Order(location: locationWithMultiple)))
        XCTAssert(testViewController.shouldLoad())
    }

    func testShouldNotLoadIfThereIsOnlyOneMenuType() {
        var proceedInWorkflowCalled = false
        let locationWithOne = Location(name: "", address: Address(), orderTypes: [], menuTypes: [.catering])
        loadFromStoryboard(args: .args(Order(location: locationWithOne)))

        testViewController.proceedInWorkflowStorage = { data in
            proceedInWorkflowCalled = true
            XCTAssertEqual((data as? Order)?.menuType, .catering)
        }

        XCTAssertFalse(testViewController.shouldLoad())
        XCTAssert(proceedInWorkflowCalled)
    }

    func testSelectingCateringProceedsInWorkflow() {
        var proceedInWorkflowCalled = false
        let locationWithMultiple = Location(name: "", address: Address(), orderTypes: [], menuTypes: [.regular, .catering])
        loadFromStoryboard(args: .args(Order(location: locationWithMultiple)))

        testViewController.proceedInWorkflowStorage = { data in
            proceedInWorkflowCalled = true
            XCTAssertEqual((data as? Order)?.menuType, .catering)
        }

        testViewController.cateringMenuButton?.simulateTouch()

        XCTAssert(proceedInWorkflowCalled)
    }

    func testSelectingRegularMenuProceedsInWorkflow() {
        var proceedInWorkflowCalled = false
        let locationWithMultiple = Location(name: "", address: Address(), orderTypes: [], menuTypes: [.regular, .catering])
        loadFromStoryboard(args: .args(Order(location: locationWithMultiple)))

        testViewController.proceedInWorkflowStorage = { data in
            proceedInWorkflowCalled = true
            XCTAssertEqual((data as? Order)?.menuType, .regular)
        }

        testViewController.regularMenuButton?.simulateTouch()

        XCTAssert(proceedInWorkflowCalled)
    }
}

fileprivate extension UIViewController {
    var cateringMenuButton: UIButton? {
        view.viewWithAccessibilityIdentifier("cateringMenuButton") as? UIButton
    }

    var regularMenuButton: UIButton? {
        view.viewWithAccessibilityIdentifier("regularMenuButton") as? UIButton
    }
}
