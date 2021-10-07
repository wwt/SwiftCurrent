//
//  PasswordFieldTests.swift
//  SwiftCurrent
//
//  Created by Richard Gist on 10/5/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import XCTest
import ViewInspector

@testable import SwiftUIExample

class PasswordFieldTests: XCTestCase {
    func testRevealButtonTogglesLayout() {
        let passwordField = PasswordField(password: Binding<String>(wrappedValue: ""))

        let exp = ViewHosting.loadView(passwordField).inspection.inspect { view in
            XCTAssertEqual(view.findAll(ViewType.Button.self).count, 1)
            XCTAssertEqual(view.findAll(ViewType.TextField.self).count, 0)
            XCTAssertEqual(view.findAll(ViewType.SecureField.self).count, 1)

            try view.find(ViewType.Button.self).tap()
            XCTAssertEqual(view.findAll(ViewType.TextField.self).count, 1)
            XCTAssertEqual(view.findAll(ViewType.SecureField.self).count, 0)

            try view.find(ViewType.Button.self).tap()
            XCTAssertEqual(view.findAll(ViewType.TextField.self).count, 0)
            XCTAssertEqual(view.findAll(ViewType.SecureField.self).count, 1)
        }

        wait(for: [exp], timeout: TestConstant.timeout)
    }

    func testPasswordIsBoundBetweenStates() {
        let password = Binding<String>(wrappedValue: "initial password")
        let expectedPassword = "This is the updated password"
        let passwordField = PasswordField(showPassword: true, password: password)

        let exp = ViewHosting.loadView(passwordField).inspection.inspect { view in
            let textField = try view.find(ViewType.TextField.self)
            XCTAssertEqual(try textField.input(), try view.actualView().password)
            XCTAssertEqual(password.wrappedValue, try view.actualView().password)

            try textField.setInput(expectedPassword)
            XCTAssertEqual(try textField.input(), expectedPassword)
            XCTAssertEqual(try view.actualView().password, expectedPassword)
            XCTAssertEqual(password.wrappedValue, expectedPassword)

            try view.find(ViewType.Button.self).tap()
            let secureField = try view.find(ViewType.SecureField.self)
            XCTAssertEqual(try secureField.input(), try view.actualView().password)
            XCTAssertEqual(try view.actualView().password, expectedPassword)
            XCTAssertEqual(password.wrappedValue, expectedPassword)

            try secureField.setInput("")
            XCTAssertEqual(try secureField.input(), "")
            XCTAssertEqual(try view.actualView().password, "")
            XCTAssertEqual(password.wrappedValue, "")
        }

        wait(for: [exp], timeout: TestConstant.timeout)
    }
}
