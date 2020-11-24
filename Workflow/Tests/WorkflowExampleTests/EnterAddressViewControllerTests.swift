//
//  EnterAddressViewControllerTests.swift
//  WorkflowExampleTests
//
//  Created by Tyler Thompson on 10/5/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import WorkflowExample

class EnterAddressViewControllerTests: ViewControllerTest<EnterAddressViewController> {
    func testViewShouldAlwaysLoad() {
        let order = Order(location: nil)
        XCTAssert(testViewController.shouldLoad(with: order))
    }
    
    func testSavingAddressProceedsInWorkflow() {
        var proceedInWorkflowCalled = false
        let order = Order(location: nil)
        testViewController.order = order
        
        testViewController.proceedInWorkflowStorage = { data in
            proceedInWorkflowCalled = true
            XCTAssertEqual((data as? Order)?.orderType, .delivery(Address()))
        }
        
        testViewController.saveAddress()
        
        XCTAssert(proceedInWorkflowCalled)
    }
}
