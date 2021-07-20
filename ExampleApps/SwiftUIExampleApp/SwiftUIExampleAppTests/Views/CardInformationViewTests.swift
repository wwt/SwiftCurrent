//
//  CardInformationViewTests.swift
//  SwiftUIExampleAppTests
//
//  Created by Tyler Thompson on 7/16/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import ViewInspector

@testable import SwiftCurrent_SwiftUI
@testable import SwiftUIExampleApp

final class CardInformationViewTests: XCTestCase {
    #warning("This might be interesting to look into")
    func testCardInformationView() throws {
        let viewUnderTest = try CardInformationView().inspect()
        XCTAssertEqual(try viewUnderTest.text().string(), "Drivers License: ")
    }
}
