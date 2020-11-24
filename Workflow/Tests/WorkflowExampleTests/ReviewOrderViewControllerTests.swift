//
//  ReviewOrderViewControllerTests.swift
//  WorkflowExampleTests
//
//  Created by Tyler Thompson on 10/5/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import WorkflowExample

class ReviewOrderViewControllerTests: ViewControllerTest<ReviewOrderViewController> {
    
    var locationNameLabel:UILabel!
    var menuLabel:UILabel!
    var orderTypeLabel:UILabel!
    var foodChoiceLabel:UILabel!
    
    override func afterLoadFromStoryboard() {
        locationNameLabel = testViewController.locationNameLabel
        menuLabel = testViewController.menuLabel
        orderTypeLabel = testViewController.orderTypeLabel
        foodChoiceLabel = testViewController.foodChoiceLabel
    }
    
    func testShouldLoad() {
        let order = Order(location: Location(name: "", address: Address(), orderTypes: [], menuTypes: []))
        XCTAssert(testViewController.shouldLoad(with: order))
    }
    
    func testShowOrderInformation() {
        let locationName = UUID().uuidString
        var order = Order(location: Location(name: locationName, address: Address(), orderTypes: [.delivery(Address())], menuTypes: [.catering]))
        order.menuType = .catering
        order.shoppingCart.append(Food(name: "Combo #1"))
        order.shoppingCart.append(Food(name: "Combo #2"))
        loadFromStoryboard {
            XCTAssert($0.shouldLoad(with: order))
        }
        
        XCTAssertEqual(locationNameLabel.text, locationName)
        XCTAssertEqual(menuLabel.text, "Catering Menu")
        XCTAssertEqual(orderTypeLabel.text, "Delivery")
        XCTAssertEqual(foodChoiceLabel.text, "Combo #1, Combo #2")
    }

}
