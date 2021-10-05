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
    static var workflowTestingData: WorkflowTestingData?
    override class func setUp() {
        NotificationReceiverLocal.register(on: .default, for: Self.self)
    }
    override class func tearDown() {
        NotificationReceiverLocal.unregister(on: .default, for: Self.self)
    }
    override func tearDown() { // swiftlint:disable:this empty_xctest_method
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

    func testLoginProceedsWorkflow() {
        let workflowFinished = expectation(description: "View Proceeded")
        let exp = ViewHosting.loadView(WorkflowLauncher(isLaunched: .constant(true)) {
            thenProceed(with: LoginView.self)
        }.onFinish { _ in
            workflowFinished.fulfill()
        }).inspection.inspect { view in
            XCTAssertNoThrow(try view.findLoginButton().tap())
        }
        wait(for: [exp, workflowFinished], timeout: TestConstant.timeout)
    }

    func testSignupCorrectlyLaunchesSignupWorkflow() throws {
        Self.workflowTestingData = nil
        var loginView: InspectableView<ViewType.View<LoginView>>!
        let exp = ViewHosting.loadView(LoginView()).inspection.inspect { view in
            loginView = view
            XCTAssertFalse(try view.actualView().showSignUp)
            XCTAssertNoThrow(try view.findSignUpButton().tap())
            XCTAssert(try view.actualView().showSignUp)
        }
        wait(for: [exp], timeout: TestConstant.timeout)

        XCTAssertNotNil(loginView)

        waitUntil(Self.workflowTestingData != nil)
        let data = Self.workflowTestingData

        // Test Workflow arrangement
        XCTAssertEqual(data?.workflow.count, 2)
        let first = data?.workflow.first { _ in true }
        XCTAssertEqual(first?.position, 0)
        XCTAssertEqual(first?.value.metadata.flowRepresentableTypeDescriptor, "\(SignUp.self)")
        XCTAssertEqual(first?.next?.value.metadata.flowRepresentableTypeDescriptor, "\(TermsAndConditions.self)")

        // Complete workflow
        (Self.workflowTestingData?.orchestrationResponder as? WorkflowViewModel)?.onFinishPublisher.send(AnyWorkflow.PassedArgs.none)

        wait(for: [
            ViewHosting.loadView(try loginView.actualView()).inspection.inspect { view in
                XCTAssertFalse(try view.actualView().showSignUp)
            }
        ], timeout: TestConstant.timeout)
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
