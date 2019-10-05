//
//  MenuSelectionViewControllerTests.swift
//  WorkflowExampleTests
//
//  Created by Tyler Thompson on 10/5/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import WorkflowExample

class MenuSelectionViewControllerTests: ViewControllerTest<MenuSelectionViewController> {
    func testShouldLoadIfThereAreMultipleMenuTypes() {
        let locationWithNone = Location(name: "", address: Address(), orderTypes: [], menuTypes: [])
        let locationWithMultiple = Location(name: "", address: Address(), orderTypes: [], menuTypes: [.regular, .catering])
        
        XCTAssertFalse(testViewController.shouldLoad(with: Order(location: locationWithNone)))
        XCTAssert(testViewController.shouldLoad(with: Order(location: locationWithMultiple)))
    }
    
    func testShouldNotLoadIfThereIsOnlyOneMenuType() {
        var proceedInWorkflowCalled = false
        let locationWithOne = Location(name: "", address: Address(), orderTypes: [], menuTypes: [.catering])
        
        testViewController.callback = { data in
            proceedInWorkflowCalled = true
            XCTAssertEqual((data as? Order)?.menuType, .catering)
        }
        
        XCTAssertFalse(testViewController.shouldLoad(with: Order(location: locationWithOne)))
        XCTAssert(proceedInWorkflowCalled)
    }
    
    func testSelectingCateringProceedsInWorkflow() {
        var proceedInWorkflowCalled = false
        let locationWithMultiple = Location(name: "", address: Address(), orderTypes: [], menuTypes: [.regular, .catering])
        testViewController.order = Order(location: locationWithMultiple)
        
        testViewController.callback = { data in
            proceedInWorkflowCalled = true
            XCTAssertEqual((data as? Order)?.menuType, .catering)
        }
        
        testViewController.cateringMenu()

        XCTAssert(proceedInWorkflowCalled)
    }

    func testSelectingRegularMenuProceedsInWorkflow() {
        var proceedInWorkflowCalled = false
        let locationWithMultiple = Location(name: "", address: Address(), orderTypes: [], menuTypes: [.regular, .catering])
        testViewController.order = Order(location: locationWithMultiple)
        
        testViewController.callback = { data in
            proceedInWorkflowCalled = true
            XCTAssertEqual((data as? Order)?.menuType, .regular)
        }
        
        testViewController.regularMenu()
        
        XCTAssert(proceedInWorkflowCalled)
    }
}
