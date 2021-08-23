//
//  SwiftUILaunchStyleAdditionTests.swift
//  SwiftCurrent_SwiftUITests
//
//  Created by Tyler Thompson on 8/22/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import SwiftCurrent

@testable import SwiftCurrent_SwiftUI

final class LaunchStyleAdditionTests: XCTestCase {
    func testPresentationTypeInitializer() {
        XCTAssertNil(LaunchStyle.SwiftUI.PresentationType(rawValue: .new))
        XCTAssertEqual(LaunchStyle.SwiftUI.PresentationType(rawValue: .default), .default)
        XCTAssertEqual(LaunchStyle.SwiftUI.PresentationType(rawValue: ._navigationLink), .navigationLink)
    }

    func testKnownPresentationTypes_AreUnique() {
        XCTAssertFalse(LaunchStyle.default === LaunchStyle._navigationLink)
        XCTAssertFalse(LaunchStyle.SwiftUI.PresentationType.default.rawValue === LaunchStyle.SwiftUI.PresentationType.navigationLink.rawValue)
    }

    func testPresentationTypes_AreCorrectlyEquatable() {
        XCTAssertEqual(LaunchStyle.SwiftUI.PresentationType.default, .default)
        XCTAssertEqual(LaunchStyle.SwiftUI.PresentationType.navigationLink, .navigationLink)
        XCTAssertNotEqual(LaunchStyle.SwiftUI.PresentationType.default, .navigationLink)
    }
}
