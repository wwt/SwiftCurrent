//
//  LaunchStyleAdditionTests.swift
//  SwiftCurrent_SwiftUITests
//
//  Created by Tyler Thompson on 8/22/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import SwiftCurrent

@testable import SwiftCurrent_SwiftUI

final class LaunchStyleAdditionTests: XCTestCase {
    func testPresentationTypeIsNil_IfInvalidLaunchStyleGiven() {
        XCTAssertNil(LaunchStyle.PresentationType(rawValue: .new))
    }

    func testKnownPresentationTypes_AreUnique() {
        XCTAssertFalse(LaunchStyle.default == LaunchStyle._navigationLink)
        XCTAssertFalse(LaunchStyle.PresentationType.default == LaunchStyle.PresentationType.navigationLink)
    }

    func testPresentationTypes_AreCorrectlyEquatable() {
        XCTAssertEqual(LaunchStyle.PresentationType.default, .default)
        XCTAssertEqual(LaunchStyle.PresentationType.navigationLink, .navigationLink)
        XCTAssertNotEqual(LaunchStyle.PresentationType.default, .navigationLink)
    }
}
