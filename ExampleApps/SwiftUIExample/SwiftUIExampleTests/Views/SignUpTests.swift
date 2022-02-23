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
    func testBasicLayout() async throws {
        let view = try await SignUp().hostAndInspect(with: \.inspection)

        XCTAssertEqual(view.findAll(PasswordField.self).count, 2, "2 password fields needed")
        XCTAssertEqual(view.findAll(ViewType.TextField.self).count, 1, "1 username field needed")
        XCTAssertNoThrow(try view.findProceedButton(), "proceed button needed")
    }

    func testContinueProceedsWorkflow() async throws {
        let workflowFinished = expectation(description: "View Proceeded")
        let launcher = try await MainActor.run {
            WorkflowView {
                WorkflowItem(SignUp.self)
            }.onFinish { _ in
                workflowFinished.fulfill()
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowItem()

        XCTAssertNoThrow(try launcher.findProceedButton().tap())
        wait(for: [workflowFinished], timeout: TestConstant.timeout)
    }
}

// test helpers
extension InspectableView {
    fileprivate func findProceedButton() throws -> InspectableView<ViewType.Button> {
        try find(PrimaryButton.self).find(ViewType.Button.self)
    }
}
