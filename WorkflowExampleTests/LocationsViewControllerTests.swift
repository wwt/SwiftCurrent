//
//  LocationsViewControllerTests.swift
//  WorkflowExampleTests
//
//  Created by Tyler Thompson on 9/25/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
import UIUTest

@testable import WorkflowExample

class LocationsViewControllerTests:XCTestCase {
    typealias ControllerType = LocationsViewController
    var testViewController:ControllerType!
    var tableView:UITableView!
    override func setUp() {
        loadFromStoryboard()
    }
    
    private func loadFromStoryboard(configure: ((ControllerType) -> Void)? = nil) {
        testViewController = UIViewController.loadFromStoryboard(identifier: ControllerType.storyboardId, configure:configure)
        tableView = testViewController.tableView
    }

    func testShouldLoadOnlyIfThereAreMultipleLocations() {
        XCTAssertFalse(testViewController.shouldLoad(with: []), "LocationsViewController should not load if there are less than 2 locations")
        XCTAssertTrue(testViewController.shouldLoad(with: [
            Location(name: "", address: Address(line1: "", line2: "", city: "", state: "", zip: ""), orderTypes: [], menuTypes: []),
            Location(name: "", address: Address(line1: "", line2: "", city: "", state: "", zip: ""), orderTypes: [], menuTypes: [])
        ]), "LocationsViewController should load if there are multiple locations")
    }
    
    func testLocationsShouldPassAlongOrderWithDefaultLocation_IfThereIsOnlyOne() {
        let rand = UUID().uuidString
        var callbackCalled = false
        loadFromStoryboard { viewController in
            viewController.callback = { data in
                callbackCalled = true
                XCTAssert(data is Order, "View should pass on data as an order object")
                XCTAssertEqual((data as? Order)?.location?.name, rand, "The location in the order should be the same one selected")
            }
            _ = viewController.shouldLoad(with: [
                Location(name: rand, address: Address(line1: "", line2: "", city: "", state: "", zip: ""), orderTypes: [], menuTypes: [])
            ])
        }
        
        XCTAssert(callbackCalled)
    }
    
    func testViewShouldTakeInLocationsData() {
        let rand1 = UUID().uuidString
        let rand2 = UUID().uuidString
        let loc1 = Location(name: rand1, address: Address(line1: "", line2: "", city: "", state: "", zip: ""), orderTypes: [], menuTypes: [])
        let loc2 = Location(name: rand2, address: Address(line1: "", line2: "", city: "", state: "", zip: ""), orderTypes: [], menuTypes: [])
        _ = testViewController.shouldLoad(with: [loc1, loc2])
        
        XCTAssertEqual(testViewController.locations.first?.name, rand1)
        XCTAssertEqual(testViewController.locations.last?.name, rand2)
    }
    
    func testTableViewShouldHaveRowsEqualToNumberOfLocations() {
        loadFromStoryboard { viewController in
            _ = viewController.shouldLoad(with: [
                Location(name: "", address: Address(line1: "", line2: "", city: "", state: "", zip: ""), orderTypes: [], menuTypes: []),
                Location(name: "", address: Address(line1: "", line2: "", city: "", state: "", zip: ""), orderTypes: [], menuTypes: [])
            ])
        }
        
        XCTAssertEqual(testViewController.tableView(tableView, numberOfRowsInSection: 0), 2)
    }
    
    func testTableViewCellShouldContainLocationName() {
        let rand = UUID().uuidString
        loadFromStoryboard { viewController in
            _ = viewController.shouldLoad(with: [
                Location(name: rand, address: Address(line1: "", line2: "", city: "", state: "", zip: ""), orderTypes: [], menuTypes: []),
                Location(name: "", address: Address(line1: "", line2: "", city: "", state: "", zip: ""), orderTypes: [], menuTypes: [])
            ])
        }
        
        let cell = testViewController.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        
        XCTAssertEqual(cell.textLabel?.text, rand)
    }
    
    func testWhenTableViewIsSelectedAnOrderShouldBeCreatedAndPassedToTheNextView() {
        let rand = UUID().uuidString
        var callbackCalled = false
        loadFromStoryboard { viewController in
            _ = viewController.shouldLoad(with: [
                Location(name: rand, address: Address(line1: "", line2: "", city: "", state: "", zip: ""), orderTypes: [], menuTypes: []),
                Location(name: "", address: Address(line1: "", line2: "", city: "", state: "", zip: ""), orderTypes: [], menuTypes: [])
            ])
            viewController.callback = { data in
                callbackCalled = true
                XCTAssert(data is Order, "View should pass on data as an order object")
                XCTAssertEqual((data as? Order)?.location?.name, rand, "The location in the order should be the same one selected")
            }
        }

        testViewController.tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        
        XCTAssert(callbackCalled)
    }
}
