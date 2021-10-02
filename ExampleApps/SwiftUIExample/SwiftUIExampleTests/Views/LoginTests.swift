//
//  LoginTests.swift
//  SwiftCurrent
//
//  Created by Richard Gist on 10/1/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

import XCTest
import SwiftUI
import ViewInspector

@testable import SwiftCurrent_SwiftUI
@testable import SwiftUIExample

final class LoginTests: XCTestCase, View, WorkflowTestingReceiver {
    static var workflowTestingData: WorkflowTestingData?
    override class func setUp() {
        NotificationReceiverLocal.register(on: .default, for: Self.self)
    }
    override class func tearDown() {
        NotificationReceiverLocal.unregister(on: .default, for: Self.self)
    }
    override func tearDown() {
        Self.workflowTestingData = nil
    }

    func testBasicLayout() {
        let exp = ViewHosting.loadView(LoginView()).inspection.inspect { view in
            XCTAssertEqual(view.findAll(ViewType.TextField.self).count, 1)
            XCTAssertEqual(view.findAll(ViewType.SecureField.self).count, 1)
            XCTAssertNoThrow(try view.findLoginButton())
            XCTAssertNoThrow(try view.findSignUpButton())
        }
        wait(for: [exp], timeout: TestConstant.timeout)
    }
}

extension InspectableView {
    fileprivate func findLoginButton() throws -> InspectableView<ViewType.Button> {
        try find(PrimaryButton.self).find(ViewType.Button.self)
    }
    fileprivate func findSignUpButton() throws -> InspectableView<ViewType.Button> {
        try find(SecondaryButton.self).find(ViewType.Button.self)
    }
}
