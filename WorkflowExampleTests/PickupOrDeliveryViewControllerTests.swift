//
//  PickupOrDeliveryViewControllerTests.swift
//  WorkflowExampleTests
//
//  Created by Tyler Thompson on 9/25/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import WorkflowExample

class PickupOrDeliveryViewConrollerTests:ViewControllerTest<PickupOrDeliveryViewController> {
    func testShouldLoadOnlyIfThereAreMultipleOrderTypes() {
        let locationWithOne = Location(name: "", address: Address(), orderTypes: [.pickup], menuTypes: [])
        let locationWithMultiple = Location(name: "", address: Address(), orderTypes: [.pickup, .delivery(Address())], menuTypes: [])
        XCTAssertFalse(testViewController.shouldLoad(with: Order(location: locationWithOne)))
        XCTAssert(testViewController.shouldLoad(with: Order(location: locationWithMultiple)))
    }
    
    func testShouldLoadWithOnlyOneOrderTypeCallsBackImmediately() {
        var callbackCalled = false
        let locationWithOne = Location(name: "", address: Address(), orderTypes: [.delivery(Address())], menuTypes: [])
        loadFromStoryboard { viewController in
            viewController.callback = { data in
                callbackCalled = true
                XCTAssert(data is Order)
                XCTAssertEqual((data as? Order)?.orderType, .delivery(Address()))
            }
            _ = viewController.shouldLoad(with: Order(location: locationWithOne))
        }
        
        XCTAssert(callbackCalled)
    }
    
    func testSelectingPickupSetsItOnOrder() {
        var callbackCalled = false
        let location = Location(name: "", address: Address(), orderTypes: [.pickup, .delivery(Address())], menuTypes: [])
        loadFromStoryboard { viewController in
            viewController.callback = { data in
                callbackCalled = true
                XCTAssert(data is Order)
                XCTAssertEqual((data as? Order)?.orderType, .pickup)
            }
            _ = viewController.shouldLoad(with: Order(location: location))
        }
        
        testViewController.selectPickup()
        
        XCTAssert(callbackCalled)
    }
}
