//
//  ChangePasswordViewTests.swift
//  SwiftUIExampleTests
//
//  Created by Tyler Thompson on 7/15/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import ViewInspector
import SwiftUI

@testable import SwiftCurrent_SwiftUI
@testable import SwiftUIExample

final class ChangePasswordViewTests: XCTestCase, View {
    func testChangePasswordView() async throws {
        let currentPassword = UUID().uuidString
        let view = try await MainActor.run {
            ChangePasswordView(with: currentPassword)
        }
        .hostAndInspect(with: \.inspection)

        XCTAssertEqual(view.findAll(PasswordField.self).count, 3)
        XCTAssertNoThrow(try view.find(ViewType.Button.self))
    }

    func testChangePasswordProceeds_IfAllInformationIsCorrect() async throws {
        let currentPassword = UUID().uuidString
        let onFinish = expectation(description: "onFinish called")
        let view = try await MainActor.run {
            WorkflowView(launchingWith: currentPassword) {
                WorkflowItem(ChangePasswordView.self)
            }
            .onFinish { _ in onFinish.fulfill() }
        }
            .content
            .hostAndInspect(with: \.inspection)
            .extractWorkflowItemWrapper()

        XCTAssertNoThrow(try view.find(ViewType.SecureField.self).setInput(currentPassword))
        XCTAssertNoThrow(try view.find(ViewType.SecureField.self, skipFound: 1).setInput("asdfF1"))
        XCTAssertNoThrow(try view.find(ViewType.SecureField.self, skipFound: 2).setInput("asdfF1"))
        XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())

        wait(for: [onFinish], timeout: TestConstant.timeout)
    }

    func testErrorsDoNotShowUp_IfFormWasNotSubmitted() async throws {
        let currentPassword = UUID().uuidString
        let view = try await MainActor.run {
            ChangePasswordView(with: currentPassword)
        }
        .hostAndInspect(with: \.inspection)

        XCTAssertNoThrow(try view.find(ViewType.SecureField.self).setInput(currentPassword))
        XCTAssertNoThrow(try view.find(ViewType.SecureField.self, skipFound: 1).setInput("asdfF1"))
        XCTAssertNoThrow(try view.find(ViewType.SecureField.self, skipFound: 2).setInput("asdfF1"))
        XCTAssertNoThrow(try view.find(ViewType.Button.self))
    }

    func testIncorrectOldPassword_PrintsError() async throws {
        let currentPassword = UUID().uuidString
        let view = try await MainActor.run {
            ChangePasswordView(with: currentPassword)
        }
        .hostAndInspect(with: \.inspection)

        XCTAssertNoThrow(try view.find(ViewType.SecureField.self).setInput("WRONG"))
        XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
        XCTAssert(try view.vStack().text(0).string().contains("Old password does not match records"))
    }

    func testPasswordsNotMatching_PrintsError() async throws {
        let currentPassword = UUID().uuidString
        let view = try await MainActor.run {
            ChangePasswordView(with: currentPassword)
        }
        .hostAndInspect(with: \.inspection)

        XCTAssertNoThrow(try view.find(ViewType.SecureField.self).setInput(currentPassword))
        XCTAssertNoThrow(try view.find(ViewType.SecureField.self, skipFound: 1).setInput(UUID().uuidString))
        XCTAssertNoThrow(try view.find(ViewType.SecureField.self, skipFound: 2).setInput(UUID().uuidString))
        XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
        XCTAssert(try view.vStack().text(0).string().contains("New password and confirmation password do not match"))
    }

    func testPasswordsNotHavingUppercase_PrintsError() async throws {
        let currentPassword = UUID().uuidString
        let view = try await MainActor.run {
            ChangePasswordView(with: currentPassword)
        }
        .hostAndInspect(with: \.inspection)

        XCTAssertNoThrow(try view.find(ViewType.SecureField.self, skipFound: 1).setInput("asdf1"))
        XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
        XCTAssert(try view.vStack().text(0).string().contains("Password must contain at least one uppercase character"))
    }

    func testPasswordsNotHavingNumber_PrintsError() async throws {
        let currentPassword = UUID().uuidString
        let view = try await MainActor.run {
            ChangePasswordView(with: currentPassword)
        }
        .hostAndInspect(with: \.inspection)

        XCTAssertNoThrow(try view.find(ViewType.SecureField.self, skipFound: 1).setInput("asdfF"))
        XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
        XCTAssert(try view.vStack().text(0).string().contains("Password must contain at least one number"))
    }
}
