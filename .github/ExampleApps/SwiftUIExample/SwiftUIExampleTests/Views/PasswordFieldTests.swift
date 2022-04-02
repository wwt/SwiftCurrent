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
    func testRevealButtonTogglesLayout() async throws {
        let passwordField = try await PasswordField(password: Binding<String>(wrappedValue: "")).hostAndInspect(with: \.inspection)

        XCTAssertEqual(passwordField.findAll(ViewType.Button.self).count, 1)
        XCTAssertEqual(passwordField.findAll(ViewType.TextField.self).count, 0)
        XCTAssertEqual(passwordField.findAll(ViewType.SecureField.self).count, 1)

        try passwordField.find(ViewType.Button.self).tap()
        XCTAssertEqual(passwordField.findAll(ViewType.TextField.self).count, 1)
        XCTAssertEqual(passwordField.findAll(ViewType.SecureField.self).count, 0)

        try passwordField.find(ViewType.Button.self).tap()
        XCTAssertEqual(passwordField.findAll(ViewType.TextField.self).count, 0)
        XCTAssertEqual(passwordField.findAll(ViewType.SecureField.self).count, 1)
    }

    func testPasswordIsBoundBetweenStates() async throws {
        let password = Binding<String>(wrappedValue: "initial password")
        let expectedPassword = "This is the updated password"
        let passwordField = try await PasswordField(showPassword: true, password: password).hostAndInspect(with: \.inspection)

        let textField = try passwordField.find(ViewType.TextField.self)
        XCTAssertEqual(try textField.input(), try passwordField.actualView().password)
        XCTAssertEqual(password.wrappedValue, try passwordField.actualView().password)

        try textField.setInput(expectedPassword)
        XCTAssertEqual(try textField.input(), expectedPassword)
        XCTAssertEqual(try passwordField.actualView().password, expectedPassword)
        XCTAssertEqual(password.wrappedValue, expectedPassword)

        try passwordField.find(ViewType.Button.self).tap()
        let secureField = try passwordField.find(ViewType.SecureField.self)
        XCTAssertEqual(try secureField.input(), try passwordField.actualView().password)
        XCTAssertEqual(try passwordField.actualView().password, expectedPassword)
        XCTAssertEqual(password.wrappedValue, expectedPassword)

        try secureField.setInput("")
        XCTAssertEqual(try secureField.input(), "")
        XCTAssertEqual(try passwordField.actualView().password, "")
        XCTAssertEqual(password.wrappedValue, "")
    }
}
