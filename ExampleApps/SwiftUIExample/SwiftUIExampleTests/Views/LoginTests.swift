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

import SwiftCurrent
@testable import SwiftCurrent_SwiftUI
@testable import SwiftUIExample

final class LoginTests: XCTestCase, View, WorkflowTestingReceiver {
    static var workflowLaunchedData = [WorkflowTestingData]()
    static var workflowTestingData: WorkflowTestingData? { workflowLaunchedData.last }

    override class func setUp() {
        NotificationReceiverLocal.register(on: .default, for: Self.self)
    }
    override class func tearDown() {
        NotificationReceiverLocal.unregister(on: .default, for: Self.self)
    }
    override func tearDown() {
        Self.workflowLaunchedData.removeAll()
    }

    func testBasicLayout() async throws {
        let view = try await LoginView().hostAndInspect(with: \.inspection)

        XCTAssertEqual(view.findAll(ViewType.TextField.self).count, 1)
        XCTAssertEqual(view.findAll(ViewType.SecureField.self).count, 1)
        XCTAssertNoThrow(try view.findLoginButton())
        XCTAssertNoThrow(try view.findSignUpButton())
    }

    func testLoginProceedsWorkflow() async throws {
        let workflowFinished = expectation(description: "View Proceeded")
        let view = try await MainActor.run {
            WorkflowView {
                WorkflowItem(LoginView.self)
            }.onFinish { _ in
                workflowFinished.fulfill()
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowItem()

        XCTAssertNoThrow(try view.findLoginButton().tap())

        wait(for: [workflowFinished], timeout: TestConstant.timeout)
    }

    func testSignupCorrectlyLaunchesSignupWorkflow() async throws {
        Self.workflowLaunchedData.removeAll()
        let loginView = try await LoginView().hostAndInspect(with: \.inspection)

        XCTAssertFalse(try loginView.actualView().showSignUp)
        XCTAssertNoThrow(try loginView.findSignUpButton().tap())
        XCTAssert(try loginView.actualView().showSignUp)

        waitUntil(Self.workflowTestingData != nil)
        let data = Self.workflowTestingData

        // Test Workflow arrangement
        XCTAssertEqual(data?.workflow.count, 2)
        let first = data?.workflow.first
        XCTAssertEqual(first?.position, 0)
        XCTAssertEqual(first?.value.metadata.flowRepresentableTypeDescriptor, "\(SignUp.self)")
        XCTAssertEqual(first?.next?.value.metadata.flowRepresentableTypeDescriptor, "\(TermsAndConditions.self)")

        // Complete workflow
        (Self.workflowTestingData?.orchestrationResponder as? WorkflowViewModel)?.onFinishPublisher.send(AnyWorkflow.PassedArgs.none)

        let view = try await loginView.actualView().hostAndInspect(with: \.inspection)
        XCTAssertFalse(try view.actualView().showSignUp)
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
