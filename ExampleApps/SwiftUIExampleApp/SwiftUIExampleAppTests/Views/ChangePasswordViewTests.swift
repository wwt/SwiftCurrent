//
//  ChangePasswordViewTests.swift
//  SwiftUIExampleAppTests
//
//  Created by Tyler Thompson on 7/15/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import ViewInspector

@testable import SwiftCurrent_SwiftUI
@testable import SwiftUIExampleApp

final class ChangePasswordViewTests: XCTestCase {
    func testChangePasswordView() throws {
        let currentPassword = UUID().uuidString
        let exp = ViewHosting.loadView(ChangePasswordView(with: currentPassword)).inspection.inspect { view in
            XCTAssertNoThrow(try view.form().textField(1))
            XCTAssertNoThrow(try view.form().textField(2))
            XCTAssertNoThrow(try view.form().textField(3))
            XCTAssertNoThrow(try view.find(ViewType.Button.self))
        }
        wait(for: [exp], timeout: 0.5)
    }

    func testChangePasswordProceeds_IfAllInformationIsCorrect() throws {
        let currentPassword = UUID().uuidString
        let onFinish = expectation(description: "onFinish called")
        let exp = ViewHosting.loadView(WorkflowView(isLaunched: .constant(true), startingArgs: currentPassword)
                                        .thenProceed(with: WorkflowItem(ChangePasswordView.self))
                                        .onFinish { _ in onFinish.fulfill() }).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ViewType.TextField.self).setInput(currentPassword))
            XCTAssertNoThrow(try view.find(ViewType.TextField.self, skipFound: 1).setInput("asdfF1"))
            XCTAssertNoThrow(try view.find(ViewType.TextField.self, skipFound: 2).setInput("asdfF1"))
            XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
        } // swiftlint:disable:this closure_end_indentation
        wait(for: [exp, onFinish], timeout: 0.5)
    }

    func testErrorsDoNotShowUp_IfFormWasNotSubmitted() throws {
        let currentPassword = UUID().uuidString
        let exp = ViewHosting.loadView(ChangePasswordView(with: currentPassword)).inspection.inspect { view in
            XCTAssertNoThrow(try view.form().textField(1).setInput(currentPassword))
            XCTAssertNoThrow(try view.form().textField(2).setInput("asdfF1"))
            XCTAssertNoThrow(try view.form().textField(3).setInput("asdfF1"))
            XCTAssertNoThrow(try view.find(ViewType.Button.self))
        }
        wait(for: [exp], timeout: 0.5)
    }

    func testIncorrectOldPassword_PrintsError() throws {
        let currentPassword = UUID().uuidString
        let exp = ViewHosting.loadView(ChangePasswordView(with: currentPassword)).inspection.inspect { view in
            XCTAssertNoThrow(try view.form().textField(1).setInput("WRONG"))
            XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
            XCTAssert(try view.form().text(0).string().contains("Old password does not match records"))
        }
        wait(for: [exp], timeout: 0.5)
    }

    func testPasswordsNotMatching_PrintsError() throws {
        let currentPassword = UUID().uuidString
        let exp = ViewHosting.loadView(ChangePasswordView(with: currentPassword)).inspection.inspect { view in
            XCTAssertNoThrow(try view.form().textField(1).setInput(currentPassword))
            XCTAssertNoThrow(try view.form().textField(2).setInput(UUID().uuidString))
            XCTAssertNoThrow(try view.form().textField(3).setInput(UUID().uuidString))
            XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
            XCTAssert(try view.form().text(0).string().contains("New password and confirmation password do not match"))
        }
        wait(for: [exp], timeout: 0.5)
    }

    func testPasswordsNotHavingUppercase_PrintsError() throws {
        let currentPassword = UUID().uuidString
        let exp = ViewHosting.loadView(ChangePasswordView(with: currentPassword)).inspection.inspect { view in
            XCTAssertNoThrow(try view.form().textField(2).setInput("asdf1"))
            XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
            XCTAssert(try view.form().text(0).string().contains("Password must contain at least one uppercase character"))
        }
        wait(for: [exp], timeout: 0.5)
    }

    func testPasswordsNotHavingNumber_PrintsError() throws {
        let currentPassword = UUID().uuidString
        let exp = ViewHosting.loadView(ChangePasswordView(with: currentPassword)).inspection.inspect { view in
            XCTAssertNoThrow(try view.form().textField(2).setInput("asdfF"))
            XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
            XCTAssert(try view.form().text(0).string().contains("Password must contain at least one number"))
        }
        wait(for: [exp], timeout: 0.5)
    }
}
