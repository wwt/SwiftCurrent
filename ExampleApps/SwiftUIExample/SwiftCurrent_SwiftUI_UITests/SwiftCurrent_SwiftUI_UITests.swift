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

    func testBackingUpWithDefaultModals() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch {
            Environment.xcuiTest(true)
            Environment.testingView(.fourItemWorkflow)
            Environment.presentationType(.FR2, .modal)
            Environment.presentationType(.FR3, .modal)
            Environment.presentationType(.FR4, .modal)
        }

        XCTAssert(app.staticTexts["This is FR1"].exists)
        app.buttons.matching(identifier: "Navigate forward").lastMatch.tap()

        XCTAssert(app.staticTexts["This is FR2"].exists)
        app.buttons.matching(identifier: "Navigate forward").lastMatch.tap()

        XCTAssert(app.staticTexts["This is FR3"].exists)
        app.buttons.matching(identifier: "Navigate forward").lastMatch.tap()

        XCTAssert(app.staticTexts["This is FR4"].exists)
        app.buttons.matching(identifier: "Navigate backward").lastMatch.tap()

        XCTAssert(app.staticTexts["This is FR3"].exists)
        app.buttons.matching(identifier: "Navigate backward").lastMatch.tap()

        XCTAssert(app.staticTexts["This is FR2"].exists)
        app.buttons.matching(identifier: "Navigate backward").lastMatch.tap()

        XCTAssert(app.staticTexts["This is FR1"].exists)
    }

    func testBackingUpWithFullScreenCovers() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch {
            Environment.xcuiTest(true)
            Environment.testingView(.fourItemWorkflow)
            Environment.presentationType(.FR2, .modal(.fullScreenCover))
            Environment.presentationType(.FR3, .modal(.fullScreenCover))
            Environment.presentationType(.FR4, .modal(.fullScreenCover))
        }

        XCTAssert(app.staticTexts["This is FR1"].exists)
        app.buttons.matching(identifier: "Navigate forward").firstMatch.tap()

        XCTAssert(app.staticTexts["This is FR2"].exists)
        app.buttons.matching(identifier: "Navigate forward").firstMatch.tap()

        XCTAssert(app.staticTexts["This is FR3"].exists)
        app.buttons.matching(identifier: "Navigate forward").element(boundBy: 1).tap()

        XCTAssert(app.staticTexts["This is FR4"].exists)
        app.buttons.matching(identifier: "Navigate backward").element(boundBy: 2).tap()

        XCTAssert(app.staticTexts["This is FR3"].exists)
        app.buttons.matching(identifier: "Navigate backward").element(boundBy: 1).tap()

        XCTAssert(app.staticTexts["This is FR2"].exists)
        app.buttons.matching(identifier: "Navigate backward").firstMatch.tap()

        XCTAssert(app.staticTexts["This is FR1"].exists)
    }

    func testBackingUpWithNavigationLinks() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch {
            Environment.xcuiTest(true)
            Environment.embedInNavStack(true)
            Environment.testingView(.fourItemWorkflow)
            Environment.presentationType(.FR1, .navigationLink)
            Environment.presentationType(.FR2, .navigationLink)
            Environment.presentationType(.FR3, .navigationLink)
        }

        XCTAssert(app.staticTexts["This is FR1"].exists)
        app.buttons["Navigate forward"].tap()

        XCTAssert(app.staticTexts["This is FR2"].exists)
        app.buttons["Navigate forward"].tap()

        XCTAssert(app.staticTexts["This is FR3"].exists)
        app.buttons["Navigate forward"].tap()

        XCTAssert(app.staticTexts["This is FR4"].exists)
        app.buttons["Navigate backward"].tap()

        XCTAssert(app.staticTexts["This is FR3"].exists)
        app.buttons["Navigate backward"].tap()

        XCTAssert(app.staticTexts["This is FR2"].exists)
        app.buttons["Navigate backward"].tap()

        XCTAssert(app.staticTexts["This is FR1"].exists)
    }
}

extension XCUIApplication {
    func launch(environment: Environment...) {
        var launchEnvironment = [String: String]()
        environment.forEach { launchEnvironment = launchEnvironment + $0.dictionaryValue }
        self.launchEnvironment = launchEnvironment
        launch()
    }

    func launch(@EnvironmentBuilder environment: () -> [Environment]) {
        var launchEnvironment = [String: String]()
        environment().forEach { launchEnvironment = launchEnvironment + $0.dictionaryValue }
        self.launchEnvironment = launchEnvironment
        launch()
    }
}

public extension Dictionary {
    static func + (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
        return lhs.merging(rhs, uniquingKeysWith: { $1 })
    }
}

@resultBuilder
struct EnvironmentBuilder {
     static func buildBlock(_ components: Environment...) -> [Environment] {
         return components
     }
}

extension XCUIElementQuery {
    var lastMatch: XCUIElement { return self.element(boundBy: self.count - 1) }
}
