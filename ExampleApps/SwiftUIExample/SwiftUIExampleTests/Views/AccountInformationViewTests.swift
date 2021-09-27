//
//  UpdatedAccountInformationViewTests.swift
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

// MARK: WORST TESTING WORKAROUND EVA!!!
class NotificationReceiverLocal: NSObject {
    @objc static func workflowLaunched(notification: Notification) {
        guard let dict = notification.object as? [String: Any?],
              let workflow = dict["workflow"] as? AnyWorkflow,
              let style = dict["style"] as? LaunchStyle,
              let responder = dict["responder"] as? OrchestrationResponder,
              let args = dict["args"] as? AnyWorkflow.PassedArgs,
              let onFinish = dict["onFinish"] as? ((AnyWorkflow.PassedArgs) -> Void)? else {
            fatalError("WorkflowLaunched notification has incorrect format, this may be because you need to update SwiftCurrent_Testing")
        }

        NotificationReceiverLocal.workflowLaunched(workflow: workflow,
                                                   responder: responder,
                                                   args: args,
                                                   style: style,
                                                   onFinish: onFinish)
    }

    static func workflowLaunched(workflow: AnyWorkflow,
                                 responder: OrchestrationResponder,
                                 args: AnyWorkflow.PassedArgs,
                                 style: LaunchStyle,
                                 onFinish: ((AnyWorkflow.PassedArgs) -> Void)?) {
        UpdatedAccountInformationViewTests.workflowTestingData = WorkflowTestingData(workflow: workflow, orchestrationResponder: responder, args: args, style: style, onFinish: onFinish)
    }
}

struct WorkflowTestingData {
    var workflow: AnyWorkflow
    var orchestrationResponder: OrchestrationResponder
    var args: AnyWorkflow.PassedArgs
    var style: LaunchStyle
    var onFinish: ((AnyWorkflow.PassedArgs) -> Void)?
}

final class UpdatedAccountInformationViewTests: XCTestCase {
    override class func setUp() {
        NotificationCenter.default.addObserver(NotificationReceiverLocal.self,
                                               selector: #selector(NotificationReceiverLocal.workflowLaunched(notification:)),
                                               name: .workflowLaunched,
                                               object: nil)
    }
    override class func tearDown() {
        NotificationCenter.default.removeObserver(NotificationReceiverLocal.self)
    }
    override func tearDown() {
        Self.workflowTestingData = nil
    }

    private typealias MFAViewWorkflowView = WorkflowLauncher<WorkflowItem<MFAView, Never, MFAView>>

    static var workflowTestingData: WorkflowTestingData?

    func testUpdatedAccountInformationView() throws {
        let exp = ViewHosting.loadView(AccountInformationView()).inspection.inspect { view in
            XCTAssertEqual(try view.find(ViewType.Text.self).string(), "Email: ")
            XCTAssertEqual(try view.find(ViewType.Text.self, skipFound: 1).string(), "SwiftCurrent@wwt.com")

            XCTAssertEqual(try view.find(ViewType.Text.self, skipFound: 2).string(), "Password: ")
            XCTAssertEqual(try view.find(ViewType.SecureField.self).input(), "supersecure")

            XCTAssertEqual(view.findAll(ViewType.Button.self).count, 2)
        }
        wait(for: [exp], timeout: TestConstant.timeout)
    }

    func testAccountInformationCanLaunchUsernameWorkflowAgnostic() throws {
        Self.workflowTestingData = nil
        var accountInformation: InspectableView<ViewType.View<AccountInformationView>>!
        let exp = ViewHosting.loadView(AccountInformationView()).inspection.inspect { view in
            accountInformation = view
            XCTAssertFalse(try view.actualView().emailWorkflowLaunched)
            XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
            XCTAssert(try view.actualView().emailWorkflowLaunched)
        }
        wait(for: [exp], timeout: TestConstant.timeout)

        XCTAssertNotNil(accountInformation)

        waitUntil(Self.workflowTestingData != nil)
        let data = Self.workflowTestingData

        if case .args(let passedInArguments) = data?.args {
            XCTAssertEqual(passedInArguments as? String, try accountInformation.actualView().email)
        } else {
            XCTFail("Arguments should be passed to workflow")
        }

        // Test Workflow arrangement
        XCTAssertEqual(data?.workflow.count, 2)
        let first = data?.workflow.first { _ in true }
        XCTAssertEqual(first?.position, 0)
        XCTAssertEqual(first?.value.metadata.flowRepresentableTypeDescriptor, "\(MFAView.self)")
        XCTAssertEqual(first?.next?.value.metadata.flowRepresentableTypeDescriptor, "\(ChangeEmailView.self)")

        // Complete workflow
        (UpdatedAccountInformationViewTests.workflowTestingData?.orchestrationResponder as? WorkflowViewModel)?.onFinishPublisher.send(.args("new email"))

        wait(for: [
            ViewHosting.loadView(try accountInformation.actualView()).inspection.inspect { view in
                XCTAssertEqual(try view.actualView().email, "new email")
                XCTAssertFalse(try view.actualView().emailWorkflowLaunched)
            }
        ], timeout: TestConstant.timeout)
    }

    func testAccountInformationDoesNotBlowUp_IfUsernameWorkflowReturnsSomethingWEIRD() throws {
        class CustomObj { }
        Self.workflowTestingData = nil
        var accountInformation: InspectableView<ViewType.View<AccountInformationView>>!
        var expectedEmail = "starting value"
        let exp = ViewHosting.loadView(AccountInformationView()).inspection.inspect { view in
            accountInformation = view
            expectedEmail = try view.actualView().email
            XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
        }
        wait(for: [exp], timeout: TestConstant.timeout)

        if Self.workflowTestingData == nil { throw XCTSkip("test data was not created") }
        (UpdatedAccountInformationViewTests.workflowTestingData?.orchestrationResponder as? WorkflowViewModel)?.onFinishPublisher.send(.args(CustomObj()))

        wait(for: [
            ViewHosting.loadView(try accountInformation.actualView()).inspection.inspect { view in
                XCTAssert(try view.actualView().emailWorkflowLaunched)
                XCTAssertEqual(try view.actualView().email, expectedEmail)
            }
        ].compactMap { $0 }, timeout: TestConstant.timeout)
    }

    func testAccountInformationCanLaunchPasswordWorkflowAgnostic() throws {
        Self.workflowTestingData = nil
        var accountInformation: InspectableView<ViewType.View<AccountInformationView>>!
        let exp = ViewHosting.loadView(AccountInformationView()).inspection.inspect { view in
            accountInformation = view
            XCTAssertFalse(try view.actualView().passwordWorkflowLaunched)
            XCTAssertNoThrow(try view.find(ViewType.Button.self, skipFound: 1).tap())
            XCTAssert(try view.actualView().passwordWorkflowLaunched)
        }
        wait(for: [exp], timeout: TestConstant.timeout)

        XCTAssertNotNil(accountInformation)

        waitUntil(Self.workflowTestingData != nil)
        let data = Self.workflowTestingData

        if case .args(let passedInArguments) = data?.args {
            XCTAssertEqual(passedInArguments as? String, try accountInformation.actualView().password)
        } else {
            XCTFail("Arguments should be passed to workflow")
        }

        // Test Workflow arrangement
        XCTAssertEqual(data?.workflow.count, 2)
        let first = data?.workflow.first { _ in true }
        XCTAssertEqual(first?.position, 0)
        XCTAssertEqual(first?.value.metadata.flowRepresentableTypeDescriptor, "\(MFAView.self)")
        XCTAssertEqual(first?.next?.value.metadata.flowRepresentableTypeDescriptor, "\(ChangePasswordView.self)")

        // Complete workflow
        (UpdatedAccountInformationViewTests.workflowTestingData?.orchestrationResponder as? WorkflowViewModel)?.onFinishPublisher.send(.args("newPassword"))

        wait(for: [
            ViewHosting.loadView(try accountInformation.actualView()).inspection.inspect { view in
                XCTAssertEqual(try view.actualView().password, "newPassword")
                XCTAssertFalse(try view.actualView().passwordWorkflowLaunched)
            }
        ], timeout: TestConstant.timeout)
    }

    func testAccountInformationDoesNotBlowUp_IfPasswordWorkflowReturnsSomethingWEIRD() throws {
        class CustomObj { }
        Self.workflowTestingData = nil
        var accountInformation: InspectableView<ViewType.View<AccountInformationView>>!
        var expectedPassword = "starting value"
        let exp = ViewHosting.loadView(AccountInformationView()).inspection.inspect { view in
            accountInformation = view
            expectedPassword = try view.actualView().password
            XCTAssertNoThrow(try view.find(ViewType.Button.self, skipFound: 1).tap())
        }
        wait(for: [exp], timeout: TestConstant.timeout)

        if Self.workflowTestingData == nil { throw XCTSkip("test data was not created") }
        (UpdatedAccountInformationViewTests.workflowTestingData?.orchestrationResponder as? WorkflowViewModel)?.onFinishPublisher.send(.args(CustomObj()))

        wait(for: [
            ViewHosting.loadView(try accountInformation.actualView()).inspection.inspect { view in
                XCTAssert(try view.actualView().passwordWorkflowLaunched)
                XCTAssertEqual(try view.actualView().password, expectedPassword)
            }
        ].compactMap { $0 }, timeout: TestConstant.timeout)
    }

    func testAccountInformationCanLaunchBothWorkflows() throws {
        let exp = ViewHosting.loadView(AccountInformationView()).inspection.inspect { view in
            XCTAssertEqual(view.findAll(MFAViewWorkflowView.self).count, 0)

            let firstButton = try view.find(ViewType.Button.self)
            let secondButton = try view.find(ViewType.Button.self, skipFound: 1)
            XCTAssertNoThrow(try secondButton.tap())
            XCTAssertNoThrow(try firstButton.tap())

            XCTAssertEqual(view.findAll(MFAViewWorkflowView.self).count, 2)
        }
        wait(for: [exp], timeout: TestConstant.timeout)
    }
}
