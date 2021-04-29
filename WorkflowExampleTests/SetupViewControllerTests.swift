//
//  SetupViewControllerTests.swift
//  WorkflowExampleTests
//
//  Created by Tyler Thompson on 10/5/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import WorkflowExample

class SetupViewControllerTests: ViewControllerTest<SetupViewController> {
    func testLaunchingMultiLocationWorkflow() {
        let listener = WorkflowListener()
        
        testViewController.launchMultiLocationWorkflow()
        
        XCTAssertWorkflowLaunched(listener: listener, expectedFlowRepresentables: [
            LocationsViewController.self,
            PickupOrDeliveryViewController.self,
            MenuSelectionViewController.self,
            FoodSelectionViewController.self,
            ReviewOrderViewController.self,
        ])
    }
}
