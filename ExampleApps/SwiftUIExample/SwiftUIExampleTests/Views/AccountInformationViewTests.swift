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

final class AccountInformationViewTests: XCTestCase, WorkflowTestingReceiver {
    static var workflowLaunchedData = [WorkflowTestingData]()
    static var workflowTestingData: WorkflowTestingData? { workflowLaunchedData.last }

    override class func setUp() {
        NotificationReceiverLocal.register(on: NotificationCenter.default, for: Self.self)
    }

    override class func tearDown() {
        NotificationReceiverLocal.unregister(on: NotificationCenter.default, for: Self.self)
    }

    override func tearDown() {
        Self.workflowLaunchedData.removeAll()
    }

    private typealias MFAViewWorkflowView = WorkflowLauncher<WorkflowItem<MFAView, Never, MFAView>>

    func testUpdatedAccountInformationView() async throws {
        let view = try await AccountInformationView().hostAndInspect(with: \.inspection)

        XCTAssertEqual(try view.find(ViewType.Text.self).string(), "Email: ")
        XCTAssertEqual(try view.find(ViewType.Text.self, skipFound: 1).string(), "SwiftCurrent@wwt.com")

        XCTAssertEqual(try view.find(ViewType.Text.self, skipFound: 2).string(), "Password: ")
        XCTAssertEqual(try view.find(ViewType.SecureField.self).input(), "supersecure")

        XCTAssertEqual(view.findAll(ViewType.Button.self).count, 2)
    }

    func testAccountInformationCanLaunchUsernameWorkflowAgnostic() async throws {
        Self.workflowLaunchedData.removeAll()

        let accountInformation = try await AccountInformationView().hostAndInspect(with: \.inspection)
        XCTAssertFalse(try accountInformation.actualView().emailWorkflowLaunched)
        XCTAssertNoThrow(try accountInformation.find(ViewType.Button.self).tap())
        XCTAssert(try accountInformation.actualView().emailWorkflowLaunched)

        waitUntil(Self.workflowTestingData != nil)
        let data = Self.workflowTestingData

        if case .args(let passedInArguments) = data?.args {
            XCTAssertEqual(passedInArguments as? String, try accountInformation.actualView().email)
        } else {
            XCTFail("Arguments should be passed to workflow")
        }

        // Test Workflow arrangement
        XCTAssertEqual(data?.workflow.count, 2)
        let first = data?.workflow.first
        XCTAssertEqual(first?.position, 0)
        XCTAssertEqual(first?.value.metadata.flowRepresentableTypeDescriptor, "\(MFAView.self)")
        XCTAssertEqual(first?.next?.value.metadata.flowRepresentableTypeDescriptor, "\(ChangeEmailView.self)")

        // Complete workflow
        (Self.workflowTestingData?.orchestrationResponder as? WorkflowViewModel)?.onFinishPublisher.send(.args("new email"))

        let view = try await accountInformation.actualView().hostAndInspect(with: \.inspection)
        XCTAssertEqual(try view.actualView().email, "new email")
        XCTAssertFalse(try view.actualView().emailWorkflowLaunched)
    }

    func testAccountInformationDoesNotBlowUp_IfUsernameWorkflowReturnsSomethingWEIRD() async throws {
        class CustomObj { }
        Self.workflowLaunchedData.removeAll()

        let accountInformation = try await AccountInformationView().hostAndInspect(with: \.inspection)
        let expectedEmail = try accountInformation.actualView().email

        XCTAssertNoThrow(try accountInformation.find(ViewType.Button.self).tap())

        waitUntil(Self.workflowTestingData != nil)

        XCTAssertNotNil(Self.workflowTestingData)
        (Self.workflowTestingData?.orchestrationResponder as? WorkflowViewModel)?.onFinishPublisher.send(.args(CustomObj()))

        let view = try await accountInformation.actualView().hostAndInspect(with: \.inspection)
        XCTAssert(try view.actualView().emailWorkflowLaunched)
        XCTAssertEqual(try view.actualView().email, expectedEmail)
    }

    func testAccountInformationCanLaunchPasswordWorkflowAgnostic() async throws {
        Self.workflowLaunchedData.removeAll()

        let accountInformation = try await AccountInformationView().hostAndInspect(with: \.inspection)

        XCTAssertFalse(try accountInformation.actualView().passwordWorkflowLaunched)
        XCTAssertNoThrow(try accountInformation.find(ViewType.Button.self, skipFound: 1).tap())
        XCTAssert(try accountInformation.actualView().passwordWorkflowLaunched)

        waitUntil(Self.workflowTestingData != nil)
        let data = Self.workflowTestingData

        if case .args(let passedInArguments) = data?.args {
            XCTAssertEqual(passedInArguments as? String, try accountInformation.actualView().password)
        } else {
            XCTFail("Arguments should be passed to workflow")
        }

        // Test Workflow arrangement
        XCTAssertEqual(data?.workflow.count, 2)
        let first = data?.workflow.first
        XCTAssertEqual(first?.position, 0)
        XCTAssertEqual(first?.value.metadata.flowRepresentableTypeDescriptor, "\(MFAView.self)")
        XCTAssertEqual(first?.next?.value.metadata.flowRepresentableTypeDescriptor, "\(ChangePasswordView.self)")

        // Complete workflow
        (Self.workflowTestingData?.orchestrationResponder as? WorkflowViewModel)?.onFinishPublisher.send(.args("newPassword"))

        let view = try await accountInformation.actualView().hostAndInspect(with: \.inspection)
        XCTAssertEqual(try view.actualView().password, "newPassword")
        XCTAssertFalse(try view.actualView().passwordWorkflowLaunched)
    }

    func testAccountInformationDoesNotBlowUp_IfPasswordWorkflowReturnsSomethingWEIRD() async throws {
        class CustomObj { }
        Self.workflowLaunchedData.removeAll()

        let accountInformation = try await AccountInformationView().hostAndInspect(with: \.inspection)
        let expectedPassword = try accountInformation.actualView().password
        XCTAssertNoThrow(try accountInformation.find(ViewType.Button.self, skipFound: 1).tap())

        waitUntil(Self.workflowTestingData != nil)
        XCTAssertNotNil(Self.workflowTestingData)

        (Self.workflowTestingData?.orchestrationResponder as? WorkflowViewModel)?.onFinishPublisher.send(.args(CustomObj()))

        let view = try await accountInformation.actualView().hostAndInspect(with: \.inspection)
        XCTAssert(try view.actualView().passwordWorkflowLaunched)
        XCTAssertEqual(try view.actualView().password, expectedPassword)
    }

    func testAccountInformationCanLaunchBothWorkflows() async throws {
        let view = try await AccountInformationView().hostAndInspect(with: \.inspection)

        XCTAssertEqual(view.findAll(MFAViewWorkflowView.self).count, 0)

        let firstButton = try view.find(ViewType.Button.self)
        let secondButton = try view.find(ViewType.Button.self, skipFound: 1)
        XCTAssertNoThrow(try secondButton.tap())
        XCTAssertNoThrow(try firstButton.tap())

        XCTAssertEqual(view.findAll(MFAViewWorkflowView.self).count, 2)
    }
}
