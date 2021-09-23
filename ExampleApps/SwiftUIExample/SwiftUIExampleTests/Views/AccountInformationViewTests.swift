//
//  AccountInformationViewTests.swift
//  SwiftUIExampleTests
//
//  Created by Tyler Thompson on 7/15/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import SwiftUI
import Swinject
import ViewInspector
import CodeScanner

import SwiftCurrent
@testable import SwiftCurrent_SwiftUI // 🤮 it sucks that this is necessary
@testable import SwiftUIExample

final class AccountInformationViewTests: XCTestCase {
    private typealias MFAViewWorkflowView = WorkflowLauncher<WorkflowItem<MFAView, Never, MFAView>>
    private typealias UsernameWorkflow = WorkflowLauncher<WorkflowItem<MFAView, WorkflowItem<ChangeEmailView, Never, ChangeEmailView>, MFAView>>
    private typealias PasswordWorkflow = WorkflowLauncher<WorkflowItem<MFAView, WorkflowItem<ChangePasswordView, Never, ChangePasswordView>, MFAView>>

    func testAccountInformationView() throws {
        let exp = ViewHosting.loadView(AccountInformationView()).inspection.inspect { view in
            XCTAssertEqual(try view.find(ViewType.Text.self).string(), "Username: changeme")
            XCTAssertEqual(view.findAll(ViewType.Button.self).count, 2)
        }
        wait(for: [exp], timeout: TestConstant.timeout)
    }

    func testAccountInformationCanLaunchUsernameWorkflow() throws {
        var usernameWorkflow: UsernameWorkflow!
        var accountInformation: InspectableView<ViewType.View<AccountInformationView>>!
        let exp = ViewHosting.loadView(AccountInformationView()).inspection.inspect { view in
            accountInformation = view
            XCTAssertNoThrow(try view.find(ViewType.Button.self, traversal: .depthFirst).tap())
            usernameWorkflow = try view.vStack().view(UsernameWorkflow.self, 0).actualView()
        }
        wait(for: [exp], timeout: TestConstant.timeout)

        XCTAssertNotNil(usernameWorkflow)

        wait(for: [
            ViewHosting.loadView(usernameWorkflow).inspection.inspect { view in
                XCTAssertNoThrow(try view.find(MFAView.self).actualView().proceedInWorkflow(.args("changeme")))
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(ChangeEmailView.self).actualView().proceedInWorkflow("newName"))
                }
            }
        ].compactMap { $0 }, timeout: TestConstant.timeout)

        wait(for: [
            ViewHosting.loadView(try accountInformation.actualView()).inspection.inspect { view in
                XCTAssertEqual(try view.find(ViewType.Text.self).string(), "Username: newName")
                XCTAssertThrowsError(try view.vStack().view(UsernameWorkflow.self, 0))
            }
        ], timeout: TestConstant.timeout)
    }

    func testAccountInformationDoesNotBlowUp_IfUsernameWorkflowReturnsSomethingWEIRD() throws {
        class CustomObj { }
        var usernameWorkflow: UsernameWorkflow!
        let exp = ViewHosting.loadView(AccountInformationView()).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ViewType.Button.self, traversal: .depthFirst).tap())
            usernameWorkflow = try view.find(UsernameWorkflow.self).actualView()
        }
        wait(for: [exp], timeout: TestConstant.timeout)

        XCTAssertNotNil(usernameWorkflow)

        wait(for: [
            ViewHosting.loadView(usernameWorkflow).inspection.inspect { view in
                XCTAssertNoThrow(try view.find(MFAView.self).actualView().proceedInWorkflow(.args("changeme")))
                try view.actualView().inspectWrapped { view in
                    XCTAssertNotNil(try view.find(ChangeEmailView.self).actualView().proceedInWorkflowStorage?(.args(CustomObj())))
                }
            }
        ].compactMap { $0 }, timeout: TestConstant.timeout)
    }

    func testAccountInformationCanLaunchPasswordWorkflow() throws {
        var passwordWorkflow: PasswordWorkflow!
        var accountInformation: InspectableView<ViewType.View<AccountInformationView>>!
        let exp = ViewHosting.loadView(AccountInformationView()).inspection.inspect { view in
            accountInformation = view
            XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
            passwordWorkflow = try view.find(PasswordWorkflow.self).actualView()
        }
        wait(for: [exp], timeout: TestConstant.timeout)

        if passwordWorkflow == nil { throw XCTSkip("passwordWorkflow failed to cast") }

        wait(for: [
            ViewHosting.loadView(passwordWorkflow).inspection.inspect { view in
                XCTAssertNoThrow(try view.find(MFAView.self).actualView().proceedInWorkflow(.args("changeme")))
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(ChangePasswordView.self).actualView().proceedInWorkflow("newPassword"))
                }
            }
        ].compactMap { $0 }, timeout: TestConstant.timeout)

        wait(for: [
            ViewHosting.loadView(try accountInformation.actualView()).inspection.inspect { view in
                XCTAssertEqual(try view.actualView().password, "newPassword")
                XCTAssertThrowsError(try view.vStack().view(PasswordWorkflow.self, 0))
            }
        ].compactMap { $0 }, timeout: TestConstant.timeout)
    }

    func testAccountInformationDoesNotBlowUp_IfPasswordWorkflowReturnsSomethingWEIRD() throws {
        class CustomObj { }
        var passwordWorkflow: PasswordWorkflow!
        let exp = ViewHosting.loadView(AccountInformationView()).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
            passwordWorkflow = try view.find(PasswordWorkflow.self).actualView()
        }
        wait(for: [exp], timeout: TestConstant.timeout)

        if passwordWorkflow == nil { throw XCTSkip("passwordWorkflow failed to cast") }

        wait(for: [
            ViewHosting.loadView(passwordWorkflow).inspection.inspect { view in
                XCTAssertNoThrow(try view.find(MFAView.self).actualView().proceedInWorkflow(.args("changeme")))
                try view.actualView().inspectWrapped { view in
                    XCTAssertNotNil(try view.find(ChangePasswordView.self).actualView().proceedInWorkflowStorage?(.args(CustomObj())))
                }
            }
        ].compactMap { $0 }, timeout: TestConstant.timeout)
    }

    func testAccountInformationCanLaunchBothWorkflows() throws {
        let exp = ViewHosting.loadView(AccountInformationView()).inspection.inspect { view in
            XCTAssertThrowsError(try view.find(UsernameWorkflow.self))
            XCTAssertThrowsError(try view.find(PasswordWorkflow.self))

            let firstButton = try view.find(ViewType.Button.self)
            let secondButton = try view.find(ViewType.Button.self, skipFound: 1)
            XCTAssertNoThrow(try secondButton.tap())
            XCTAssertNoThrow(try firstButton.tap())

            XCTAssertNoThrow(try view.vStack().view(MFAViewWorkflowView.self, 0))
            XCTAssertNoThrow(try view.vStack().view(MFAViewWorkflowView.self, 1))
        }
        wait(for: [exp], timeout: TestConstant.timeout)
    }
}
