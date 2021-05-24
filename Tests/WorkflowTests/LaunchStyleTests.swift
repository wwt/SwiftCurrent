//
//  LaunchStyleTests.swift
//  
//
//  Created by Tyler Thompson on 11/26/20.
//

import Foundation
import XCTest
import Workflow

class LaunchStyleTests: XCTestCase {
    func testCreatingNewLaunchStylesNeverHasTheSameInstance() {
        (1...10).forEach { _ in
            XCTAssertFalse( LaunchStyle.new === LaunchStyle.new )
        }
    }

    func testLaunchStyleIsEquatableByReference() {
        let ref = LaunchStyle.new
        XCTAssertEqual(ref, ref)
        XCTAssertNotEqual(ref, LaunchStyle.new)
        XCTAssertEqual(LaunchStyle.default, LaunchStyle.default)
    }
}
