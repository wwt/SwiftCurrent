//
//  SwiftCurrent_SwiftUI_UITests.swift
//  SwiftCurrent_SwiftUI_UITests
//
//  Created by Richard Gist on 9/1/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest

class SwiftCurrent_SwiftUI_UITests: XCTestCase {

    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    func testCustomLaunch() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch(environment: .xcuiTest(true),
                   .testingView(.oneItemWorkflow))

        let foo2 = app.staticTexts["Important variable"]
        XCTAssertFalse(foo2.exists)
    }
}

extension XCUIApplication {
    func launch(environment: Environment...) {
        var launchEnvironment = [String: String]()
        environment.forEach { launchEnvironment = launchEnvironment + $0.dictionaryValue }
        self.launchEnvironment = launchEnvironment
        launch()
    }
}

public extension Dictionary {
    static func + (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
        return lhs.merging(rhs, uniquingKeysWith: { $1 })
    }
}
