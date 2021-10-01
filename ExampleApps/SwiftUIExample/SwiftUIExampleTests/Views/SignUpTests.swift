//
//  SignUpTests.swift
//  SwiftCurrent
//
//  Created by Richard Gist on 10/1/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

import XCTest
import SwiftUI
import ViewInspector

@testable import SwiftCurrent_SwiftUI // 🤮 it sucks that this is necessary
@testable import SwiftUIExample

final class SignUpTests: XCTestCase, View {
    func testBasicLayout() {
        let exp = ViewHosting.loadView(SignUp()).inspection.inspect { view in
            XCTAssertEqual(view.findAll(ViewType.SecureField.self).count, 2, "2 password fields needed")
            XCTAssertEqual(view.findAll(ViewType.TextField.self).count, 1, "1 username field needed")
            XCTAssertNoThrow(try view.findProceedButton(), "proceed button needed")
        }
        wait(for: [exp], timeout: TestConstant.timeout)
    }

    func testPasswordFieldsWereUsedAndConfigured() {
        let exp = ViewHosting.loadView(SignUp()).inspection.inspect { view in
            XCTAssertEqual(view.findAll(PasswordField.self).count, 2, "If the 2 SecureFields are PasswordFields we can skip testing visible scenarios")

            try view.findAll(PasswordField.self).first?.find(ViewType.Button.self).tap()
            XCTAssertNoThrow(try view.findAll(PasswordField.self).first?.find(ViewType.TextField.self), "Should have started with secure field and properly tied to state")

            try view.findAll(PasswordField.self).last?.find(ViewType.Button.self).tap()
            XCTAssertNoThrow(try view.findAll(PasswordField.self).last?.find(ViewType.TextField.self), "Should have started with secure field and properly tied to state")
        }
        wait(for: [exp], timeout: TestConstant.timeout)
    }

    func testContinueProceedsWorkflow() {
        let workflowFinished = expectation(description: "View Proceeded")
        let exp = ViewHosting.loadView(WorkflowLauncher(isLaunched: .constant(true)) {
            thenProceed(with: SignUp.self)
        }.onFinish { _ in
            workflowFinished.fulfill()
        }).inspection.inspect { view in
            XCTAssertNoThrow(try view.findProceedButton().tap())
        }
        wait(for: [exp, workflowFinished], timeout: TestConstant.timeout)
    }
}

// test helpers
extension InspectableView {
    fileprivate func findProceedButton() throws -> InspectableView<ViewType.Button> {
        try find(PrimaryButton.self).find(ViewType.Button.self)
    }
}
