//
//  MapFeatureViewTests.swift
//  SwiftUIExampleAppTests
//
//  Created by Tyler Thompson on 7/15/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import ViewInspector

@testable import SwiftUIExampleApp

final class MapFeatureViewTests: XCTestCase {
    func testMapFeatureView() throws {
        let exp = ViewHosting.loadView(MapFeatureView()).inspection.inspect { view in
            let map = try view.map()
            let region = try map.coordinateRegion()
            XCTAssertEqual(region.center.latitude, 38.70196, accuracy: 0.9) // swiftlint:disable:this number_separator
            XCTAssertEqual(region.center.longitude, -90.44906, accuracy: 0.9) // swiftlint:disable:this number_separator
        }
        wait(for: [exp], timeout: TestConstant.timeout)
    }
}
