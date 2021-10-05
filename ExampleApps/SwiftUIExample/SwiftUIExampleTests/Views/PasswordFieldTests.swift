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
    func testLayoutIsCorrect() {
        struct HostingView: View, Inspectable {
            @State var showPassword = false
            @State var password = ""
            let inspection = Inspection<Self>()

            var body: some View {
                PasswordField(showPassword: $showPassword, password: $password)
                    .onReceive(inspection.notice) { inspection.visit(self, $0) }
            }
        }
        let exp = ViewHosting.loadView(HostingView()).inspection.inspect { view in
            XCTAssertEqual(view.findAll(ViewType.TextField.self).count, 0)
            XCTAssertEqual(view.findAll(ViewType.SecureField.self).count, 1)

            try view.actualView().showPassword = true
            XCTAssertEqual(view.findAll(ViewType.TextField.self).count, 1)
            XCTAssertEqual(view.findAll(ViewType.SecureField.self).count, 0)
        }

        wait(for: [exp], timeout: TestConstant.timeout)
    }

    func testPasswordBindingIsConnected() {
        struct HostingView: View, Inspectable {
            @State var showPassword = false
            @State var password = "initial password"
            let inspection = Inspection<Self>()

            var body: some View {
                PasswordField(showPassword: $showPassword, password: $password)
                    .onReceive(inspection.notice) { inspection.visit(self, $0) }
            }
        }
        let expectedPassword = "This is the updated password"
        let exp = ViewHosting.loadView(HostingView()).inspection.inspect { view in
            let secureField = try view.find(ViewType.SecureField.self)
            XCTAssertEqual(try secureField.input(), try view.actualView().password)

            try secureField.setInput(expectedPassword)
            XCTAssertEqual(try secureField.input(), expectedPassword)
            XCTAssertEqual(try view.actualView().password, expectedPassword)

            try view.actualView().showPassword = true
            let visibleField = try view.find(ViewType.TextField.self)
            XCTAssertEqual(try visibleField.input(), try view.actualView().password)
            XCTAssertEqual(try view.actualView().password, expectedPassword)

            try visibleField.setInput("")
            XCTAssertEqual(try visibleField.input(), "")
            XCTAssertEqual(try view.actualView().password, "")
        }

        wait(for: [exp], timeout: TestConstant.timeout)
    }

    func testRevealButtonTogglesBinding() {
        struct HostingView: View, Inspectable {
            @State var showPassword = true
            @State var password = ""
            let inspection = Inspection<Self>()

            var body: some View {
                PasswordField(showPassword: $showPassword, password: $password)
                    .onReceive(inspection.notice) { inspection.visit(self, $0) }
            }
        }
        let exp = ViewHosting.loadView(HostingView()).inspection.inspect { view in
            XCTAssertEqual(view.findAll(ViewType.Button.self).count, 1)

            try view.find(ViewType.Button.self).tap()
            XCTAssertFalse(try view.actualView().showPassword)

            try view.find(ViewType.Button.self).tap()
            XCTAssertTrue(try view.actualView().showPassword)
        }

        wait(for: [exp], timeout: TestConstant.timeout)
    }
}
