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

@testable import SwiftCurrent_SwiftUI // 🤮 it sucks that this is necessary
@testable import SwiftUIExample

final class AccountInformationViewTests: XCTestCase {
    func testAccountInformationView() throws {
        let exp = ViewHosting.loadView(AccountInformationView()).inspection.inspect { view in
            XCTAssertEqual(try view.find(ViewType.Text.self).string(), "Username: changeme")
            XCTAssertEqual(try view.find(ViewType.Button.self, traversal: .depthFirst).labelView().text().string(), "Change Username")
            XCTAssertEqual(try view.find(ViewType.Button.self).labelView().text().string(), "Change Password")
        }
        wait(for: [exp], timeout: TestConstant.timeout)
    }

    func testAccountInformationCanLaunchUsernameWorkflow() throws {
        var usernameWorkflow: WorkflowView<String>!
        var accountInformation: InspectableView<ViewType.View<AccountInformationView>>!
        let exp = ViewHosting.loadView(AccountInformationView()).inspection.inspect { view in
            accountInformation = view
            XCTAssertNoThrow(try view.find(ViewType.Button.self, traversal: .depthFirst).tap())
            usernameWorkflow = try view.find(WorkflowView<String>.self).actualView()
        }
        wait(for: [exp], timeout: TestConstant.timeout)

        XCTAssertNotNil(usernameWorkflow)

        wait(for: [
            ViewHosting.loadView(usernameWorkflow)?.inspection.inspect { view in
                XCTAssertNoThrow(try view.find(MFAView.self).actualView().proceedInWorkflow(.args("changeme")))
                XCTAssertNoThrow(try view.find(ChangeUsernameView.self).actualView().proceedInWorkflow("newName"))
                XCTAssertEqual(try accountInformation.find(ViewType.Text.self).string(), "Username: newName")
                XCTAssertThrowsError(try accountInformation.find(WorkflowView<String>.self))
            }
        ].compactMap { $0 }, timeout: TestConstant.timeout)
    }

    func testAccountInformationDoesNotBlowUp_IfUsernameWorkflowReturnsSomethingWEIRD() throws {
        class CustomObj { }
        var usernameWorkflow: WorkflowView<String>!
        let exp = ViewHosting.loadView(AccountInformationView()).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ViewType.Button.self, traversal: .depthFirst).tap())
            usernameWorkflow = try view.find(WorkflowView<String>.self).actualView()
        }
        wait(for: [exp], timeout: TestConstant.timeout)

        XCTAssertNotNil(usernameWorkflow)

        wait(for: [
            ViewHosting.loadView(usernameWorkflow)?.inspection.inspect { view in
                XCTAssertNoThrow(try view.find(MFAView.self).actualView().proceedInWorkflow(.args("changeme")))
                XCTAssertNotNil(try view.find(ChangeUsernameView.self).actualView().proceedInWorkflowStorage?(.args(CustomObj())))
            }
        ].compactMap { $0 }, timeout: TestConstant.timeout)
    }

    func testAccountInformationCanLaunchPasswordWorkflow() throws {
        var passwordWorkflow: WorkflowView<String>!
        var accountInformation: InspectableView<ViewType.View<AccountInformationView>>!
        let exp = ViewHosting.loadView(AccountInformationView()).inspection.inspect { view in
            accountInformation = view
            XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
            passwordWorkflow = try view.find(WorkflowView<String>.self).actualView()
        }
        wait(for: [exp], timeout: TestConstant.timeout)

        XCTAssertNotNil(passwordWorkflow)

        wait(for: [
            ViewHosting.loadView(passwordWorkflow)?.inspection.inspect { view in
                XCTAssertNoThrow(try view.find(MFAView.self).actualView().proceedInWorkflow(.args("changeme")))
                XCTAssertNoThrow(try view.find(ChangePasswordView.self).actualView().proceedInWorkflow("newPassword"))
                XCTAssertEqual(try accountInformation.actualView().password, "newPassword")
                XCTAssertThrowsError(try accountInformation.find(WorkflowView<String>.self))
            }
        ].compactMap { $0 }, timeout: TestConstant.timeout)
    }

    func testAccountInformationDoesNotBlowUp_IfPasswordWorkflowReturnsSomethingWEIRD() throws {
        class CustomObj { }
        var passwordWorkflow: WorkflowView<String>!
        let exp = ViewHosting.loadView(AccountInformationView()).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
            passwordWorkflow = try view.find(WorkflowView<String>.self).actualView()
        }
        wait(for: [exp], timeout: TestConstant.timeout)

        XCTAssertNotNil(passwordWorkflow)

        wait(for: [
            ViewHosting.loadView(passwordWorkflow)?.inspection.inspect { view in
                XCTAssertNoThrow(try view.find(MFAView.self).actualView().proceedInWorkflow(.args("changeme")))
                XCTAssertNotNil(try view.find(ChangePasswordView.self).actualView().proceedInWorkflowStorage?(.args(CustomObj())))
            }
        ].compactMap { $0 }, timeout: TestConstant.timeout)
    }

    func testAccountInformationCanLaunchBothWorkflows() throws {
        let exp = ViewHosting.loadView(AccountInformationView()).inspection.inspect { view in
            XCTAssertEqual(view.findAll(WorkflowView<String>.self).count, 0)

            let firstButton = try view.find(ViewType.Button.self)
            let secondButton = try view.find(ViewType.Button.self, skipFound: 1)
            XCTAssertNoThrow(try secondButton.tap())
            XCTAssertNoThrow(try firstButton.tap())

            XCTAssertEqual(view.findAll(WorkflowView<String>.self).count, 2)
        }
        wait(for: [exp], timeout: TestConstant.timeout)
    }
}
