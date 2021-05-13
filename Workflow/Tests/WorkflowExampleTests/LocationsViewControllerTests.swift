//
//  LocationsViewControllerTests.swift
//  WorkflowExampleTests
//
//  Created by Tyler Thompson on 9/25/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
import UIUTest

@testable import WorkflowExample

class LocationsViewControllerTests: ViewControllerTest<LocationsViewController> {
    func testShouldLoadOnlyIfThereAreMultipleLocations() {
        loadFromStoryboard(args: .args([Location]()))
        XCTAssertFalse(testViewController.shouldLoad(), "LocationsViewController should not load if there are less than 2 locations")

        loadFromStoryboard(args: .args([
            Location(name: "", address: Address(line1: "", line2: "", city: "", state: "", zip: ""), orderTypes: [], menuTypes: []),
            Location(name: "", address: Address(line1: "", line2: "", city: "", state: "", zip: ""), orderTypes: [], menuTypes: [])
        ]))
        XCTAssertTrue(testViewController.shouldLoad(), "LocationsViewController should load if there are multiple locations")
    }

    func testLocationsShouldPassAlongOrderWithDefaultLocation_IfThereIsOnlyOne() {
        let rand = UUID().uuidString
        var callbackCalled = false
        let locations = [
            Location(name: rand, address: Address(line1: "", line2: "", city: "", state: "", zip: ""), orderTypes: [], menuTypes: [])
        ]
        loadFromStoryboard(args: .args(locations)) { viewController in
            viewController._proceedInWorkflow = { data in
                callbackCalled = true
                XCTAssert(data is Order, "View should pass on data as an order object")
                XCTAssertEqual((data as? Order)?.location?.name, rand, "The location in the order should be the same one selected")
            }
        }

        XCTAssert(callbackCalled)
    }

    func testViewShouldTakeInLocationsData() {
        let rand1 = UUID().uuidString
        let rand2 = UUID().uuidString
        let loc1 = Location(name: rand1, address: Address(line1: "", line2: "", city: "", state: "", zip: ""), orderTypes: [], menuTypes: [])
        let loc2 = Location(name: rand2, address: Address(line1: "", line2: "", city: "", state: "", zip: ""), orderTypes: [], menuTypes: [])
        loadFromStoryboard(args: .args([loc1, loc2]))

        XCTAssertEqual(testViewController.locations.first?.name, rand1)
        XCTAssertEqual(testViewController.locations.last?.name, rand2)
    }

    func testTableViewShouldHaveRowsEqualToNumberOfLocations() {
        let locations = [
            Location(name: "", address: Address(line1: "", line2: "", city: "", state: "", zip: ""), orderTypes: [], menuTypes: []),
            Location(name: "", address: Address(line1: "", line2: "", city: "", state: "", zip: ""), orderTypes: [], menuTypes: [])
        ]
        loadFromStoryboard(args: .args(locations))

        XCTAssertEqual(testViewController.tableView(testViewController.tableView, numberOfRowsInSection: 0), 2)
    }

    func testTableViewCellShouldContainLocationName() {
        let rand = UUID().uuidString
        let locations = [
            Location(name: rand, address: Address(line1: "", line2: "", city: "", state: "", zip: ""), orderTypes: [], menuTypes: []),
            Location(name: "", address: Address(line1: "", line2: "", city: "", state: "", zip: ""), orderTypes: [], menuTypes: [])
        ]
        loadFromStoryboard(args: .args(locations))

        let cell = testViewController.tableView(testViewController.tableView, cellForRowAt: IndexPath(row: 0, section: 0))

        XCTAssertEqual(cell.textLabel?.text, rand)
    }

    func testWhenTableViewIsSelectedAnOrderShouldBeCreatedAndPassedToTheNextView() {
        let rand = UUID().uuidString
        var callbackCalled = false
        let locations = [
            Location(name: rand, address: Address(line1: "", line2: "", city: "", state: "", zip: ""), orderTypes: [], menuTypes: []),
            Location(name: "", address: Address(line1: "", line2: "", city: "", state: "", zip: ""), orderTypes: [], menuTypes: [])
        ]
        loadFromStoryboard(args: .args(locations)) { viewController in
            viewController._proceedInWorkflow = { data in
                callbackCalled = true
                XCTAssert(data is Order, "View should pass on data as an order object")
                XCTAssertEqual((data as? Order)?.location?.name, rand, "The location in the order should be the same one selected")
            }
        }

        testViewController.tableView.simulateTouch(at: IndexPath(row: 0, section: 0))

        XCTAssert(callbackCalled)
    }
}

fileprivate extension UIViewController {
    var tableView: UITableView! {
        view.viewWithAccessibilityIdentifier("tableView") as? UITableView
    }
}
