//
//  SwiftUILaunchStyleAdditionTests.swift
//  SwiftCurrent_SwiftUITests
//
//  Created by Tyler Thompson on 8/22/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import SwiftCurrent
import Algorithms
import SwiftUI

@testable import SwiftCurrent_SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class LaunchStyleAdditionTests: XCTestCase, View {
    override func tearDownWithError() throws {
        removeQueuedExpectations()
    }
    
    func testPresentationTypeInitializer() {
        XCTAssertNil(LaunchStyle.SwiftUI.PresentationType(rawValue: .new))
        XCTAssertEqual(LaunchStyle.SwiftUI.PresentationType(rawValue: .default), .default)
        XCTAssertEqual(LaunchStyle.SwiftUI.PresentationType(rawValue: ._swiftUI_navigationLink), .navigationLink)
    }

    func testKnownPresentationTypes_AreUnique() {
        [LaunchStyle.default, LaunchStyle._swiftUI_modal, LaunchStyle._swiftUI_modal_fullscreen, LaunchStyle._swiftUI_navigationLink].permutations().forEach {
            XCTAssertFalse($0[0] === $0[1])
        }
        LaunchStyle.SwiftUI.PresentationType.allCases.permutations().forEach {
            XCTAssertNotEqual($0[0], $0[1])
        }
    }

    func testPresentationTypes_AreCorrectlyEquatable() {
        XCTAssertEqual(LaunchStyle.SwiftUI.PresentationType.default, .default)
        XCTAssertEqual(LaunchStyle.SwiftUI.PresentationType.navigationLink, .navigationLink)
        XCTAssertNotEqual(LaunchStyle.SwiftUI.PresentationType.default, .navigationLink)
    }
}
