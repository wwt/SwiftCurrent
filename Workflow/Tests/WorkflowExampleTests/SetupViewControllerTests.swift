//
//  SetupViewControllerTests.swift
//  WorkflowExampleTests
//
//  Created by Tyler Thompson on 10/5/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import WorkflowExample
import Workflow

class SetupViewControllerTests: XCTestCase {
    var testViewController: SetupViewController!

    override func setUp() {
        testViewController = UIViewController.loadFromStoryboard(identifier: "SetupViewController")
    }

    func testLaunchingMultiLocationWorkflow() {
        let listener = WorkflowListener()

        testViewController.launchWorkflowButton?.simulateTouch()

        XCTAssertWorkflowLaunched(listener: listener, workflow: Workflow(LocationsViewController.self)
                                    .thenPresent(PickupOrDeliveryViewController.self)
                                    .thenPresent(MenuSelectionViewController.self)
                                    .thenPresent(FoodSelectionViewController.self)
                                    .thenPresent(ReviewOrderViewController.self),
                                  passedArgs: [
                                    .args([Location]()),
                                    .args(Order(location: nil)),
                                    .args(Order(location: nil)),
                                    .args(Order(location: nil)),
                                    .args(Order(location: nil)),
                                  ])
    }
}

fileprivate extension UIViewController {
    var launchWorkflowButton: UIButton? {
        view.viewWithAccessibilityIdentifier("launchWorkflowButton") as? UIButton
    }
}
