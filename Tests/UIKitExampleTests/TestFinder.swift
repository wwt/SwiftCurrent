//
//  TestFinder.swift
//  UIKitExampleTests
//
//  Created by Tyler Thompson on 10/5/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

class TestFinder: XCTestCase {

    override class var defaultTestSuite: XCTestSuite {
        let suite = XCTestSuite(forTestCaseClass: TestFinder.self)
        XCTestSuite(forTestCaseClass: LocationsViewControllerTests.self).tests.forEach { suite.addTest($0) }
        XCTestSuite(forTestCaseClass: PickupOrDeliveryViewControllerTests.self).tests.forEach { suite.addTest($0) }
        XCTestSuite(forTestCaseClass: MenuSelectionViewControllerTests.self).tests.forEach { suite.addTest($0) }
        XCTestSuite(forTestCaseClass: FoodSelectionViewControllerTests.self).tests.forEach { suite.addTest($0) }
        XCTestSuite(forTestCaseClass: ReviewOrderViewControllerTests.self).tests.forEach { suite.addTest($0) }
        XCTestSuite(forTestCaseClass: EnterAddressViewControllerTests.self).tests.forEach { suite.addTest($0) }
        XCTestSuite(forTestCaseClass: SetupViewControllerTests.self).tests.forEach { suite.addTest($0) }
        return suite
    }

    func testingStarts() { XCTAssert(true) }
}
