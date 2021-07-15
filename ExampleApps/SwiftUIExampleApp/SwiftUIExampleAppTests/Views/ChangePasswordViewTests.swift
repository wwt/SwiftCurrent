//
//  ChangePasswordViewTests.swift
//  SwiftUIExampleAppTests
//
//  Created by Tyler Thompson on 7/15/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import ViewInspector

@testable import SwiftUIExampleApp

final class ChangePasswordViewTests: XCTestCase {
    func testChangePasswordView() throws {
        let currentPassword = UUID().uuidString
        let exp = ViewHosting.loadView(ChangePasswordView(with: currentPassword)).inspection.inspect { view in
            let oldPasswordField = try view.form().textField(1)
            let newPassword = try view.form().textField(2)
            let confirmNewPassword = try view.form().textField(3)
            let saveButton = try view.find(ViewType.Button.self)
            
        }
        wait(for: [exp], timeout: 0.3)
    }
}
