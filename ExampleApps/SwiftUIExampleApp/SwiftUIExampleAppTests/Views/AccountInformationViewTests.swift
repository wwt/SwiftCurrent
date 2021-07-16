//
//  AccountInformationViewTests.swift
//  SwiftUIExampleAppTests
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
@testable import SwiftUIExampleApp

final class AccountInformationViewTests: XCTestCase {
    func testAccountInformationView() throws {
        let exp = ViewHosting.loadView(AccountInformationView()).inspection.inspect { view in
            XCTAssertEqual(try view.find(ViewType.Text.self).string(), "Username: changeme")
            XCTAssertEqual(try view.find(ViewType.Button.self, traversal: .depthFirst).labelView().text().string(), "Change Username")
            XCTAssertEqual(try view.find(ViewType.Button.self).labelView().text().string(), "Change Password")
        }
        wait(for: [exp], timeout: 0.5)
    }

    func testAccountInformationCanLaunchUsernameWorkflow() throws {
        var usernameWorkflow: WorkflowView<String>!
        var accountInformation: InspectableView<ViewType.View<AccountInformationView>>!
        let exp = ViewHosting.loadView(AccountInformationView()).inspection.inspect { view in
            accountInformation = view
            XCTAssertNoThrow(try view.find(ViewType.Button.self, traversal: .depthFirst).tap())
            usernameWorkflow = try view.find(WorkflowView<String>.self).actualView()
        }
        wait(for: [exp], timeout: 0.5)

        XCTAssertNotNil(usernameWorkflow)

        wait(for: [
            ViewHosting.loadView(usernameWorkflow)?.inspection.inspect { view in
                XCTAssertNoThrow(try view.find(MFAuthenticationView.self).actualView().proceedInWorkflow(.args("changeme")))
                XCTAssertNoThrow(try view.find(ChangeUsernameView.self).actualView().proceedInWorkflow("newName"))
                XCTAssertEqual(try accountInformation.find(ViewType.Text.self).string(), "Username: newName")
            }
        ].compactMap { $0 }, timeout: 0.5)
    }

    func testAccountInformationDoesNotBlowUp_IfUsernameWorkflowReturnsSomethingWEIRD() throws {
        class CustomObj { }
        var usernameWorkflow: WorkflowView<String>!
        let exp = ViewHosting.loadView(AccountInformationView()).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ViewType.Button.self, traversal: .depthFirst).tap())
            usernameWorkflow = try view.find(WorkflowView<String>.self).actualView()
        }
        wait(for: [exp], timeout: 0.5)

        XCTAssertNotNil(usernameWorkflow)

        wait(for: [
            ViewHosting.loadView(usernameWorkflow)?.inspection.inspect { view in
                XCTAssertNoThrow(try view.find(MFAuthenticationView.self).actualView().proceedInWorkflow(.args("changeme")))
                XCTAssertNotNil(try view.find(ChangeUsernameView.self).actualView().proceedInWorkflowStorage?(.args(CustomObj())))
            }
        ].compactMap { $0 }, timeout: 0.5)
    }
}
