//
//  ReviewOrderViewControllerTests.swift
//  WorkflowExampleTests
//
//  Created by Tyler Thompson on 10/5/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import WorkflowExample

class ReviewOrderViewControllerTests: ViewControllerTest<ReviewOrderViewController> {

    func testShouldLoad() {
        let order = Order(location: Location(name: "", address: Address(), orderTypes: [], menuTypes: []))
        loadFromStoryboard(args: .args(order))
        XCTAssert(testViewController.shouldLoad(with: order))
    }

    func testShowOrderInformation() {
        let locationName = UUID().uuidString
        var order = Order(location: Location(name: locationName, address: Address(), orderTypes: [.delivery(Address())], menuTypes: [.catering]))
        order.menuType = .catering
        order.shoppingCart.append(Food(name: "Combo #1"))
        order.shoppingCart.append(Food(name: "Combo #2"))
        loadFromStoryboard(args: .args(order)) {
            XCTAssert($0.shouldLoad(with: order))
        }

        XCTAssertEqual(testViewController.locationNameLabel?.text, locationName)
        XCTAssertEqual(testViewController.menuLabel?.text, "Catering Menu")
        XCTAssertEqual(testViewController.orderTypeLabel?.text, "Delivery")
        XCTAssertEqual(testViewController.foodChoiceLabel?.text, "Combo #1, Combo #2")
    }

}

fileprivate extension UIViewController {
    var locationNameLabel: UILabel? {
        view.viewWithAccessibilityIdentifier("locationNameLabel") as? UILabel
    }

    var menuLabel: UILabel? {
        view.viewWithAccessibilityIdentifier("menuLabel") as? UILabel
    }

    var orderTypeLabel: UILabel? {
        view.viewWithAccessibilityIdentifier("orderTypeLabel") as? UILabel
    }

    var foodChoiceLabel: UILabel? {
        view.viewWithAccessibilityIdentifier("foodChoiceLabel") as? UILabel
    }
}
