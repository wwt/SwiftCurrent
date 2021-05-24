//
//  EnterAddressViewControllerTests.swift
//  WorkflowExampleTests
//
//  Created by Tyler Thompson on 10/5/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
import UIUTest

@testable import WorkflowExample

class EnterAddressViewControllerTests: ViewControllerTest<EnterAddressViewController> {
    func testViewShouldAlwaysLoad() {
        let order = Order(location: nil)
        loadFromStoryboard(args: .args(order))
        XCTAssert(testViewController.shouldLoad())
    }

    func testSavingAddressProceedsInWorkflow() {
        var proceedInWorkflowCalled = false
        let order = Order(location: nil)
        loadFromStoryboard(args: .args(order))

        testViewController._proceedInWorkflow = { data in
            proceedInWorkflowCalled = true
            XCTAssertEqual((data as? Order)?.orderType, .delivery(Address()))
        }

        testViewController.saveAddressButton?.simulateTouch()

        XCTAssert(proceedInWorkflowCalled)
    }
}

fileprivate extension UIViewController {
    var saveAddressButton: UIButton? {
        view.viewWithAccessibilityIdentifier("saveAddressButton") as? UIButton
    }
}
