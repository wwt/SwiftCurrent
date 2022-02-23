//
//  TermsAndConditionsTests.swift
//  SwiftCurrent
//
//  Created by Richard Gist on 10/1/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  swiftlint:disable multiline_function_chains

import XCTest
import SwiftUI
import ViewInspector

@testable import SwiftCurrent_SwiftUI // 🤮 it sucks that this is necessary
@testable import SwiftUIExample

final class TermsAndConditionsTests: XCTestCase, View {
    func testLayout() async throws {
        let view = try await TermsAndConditions().hostAndInspect(with: \.inspection)

        XCTAssertEqual(view.findAll(ViewType.Button.self).count, 2)
    }

    func testPrimaryAcceptButtonCompletesWorkflow() async throws {
        let workflowFinished = expectation(description: "View Proceeded")
        let launcher = try await MainActor.run {
            WorkflowView {
                WorkflowItem(TermsAndConditions.self)
            }.onAbandon {
                XCTFail("Abandon should not have been called")
            }.onFinish { _ in
                workflowFinished.fulfill()
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowItem()

        let primaryButton = try launcher.find(PrimaryButton.self) // ToS should have a primary call to accept
        XCTAssertEqual(try primaryButton.find(ViewType.Text.self).string(), "Accept")
        XCTAssertNoThrow(try primaryButton.find(ViewType.Button.self).tap())

        wait(for: [workflowFinished], timeout: TestConstant.timeout)
    }

    func testSecondaryRejectButtonAbandonsWorkflow() async throws {
        let workflowAbandoned = expectation(description: "View Proceeded")
        let launcher = try await MainActor.run {
            WorkflowView {
                WorkflowItem(TermsAndConditions.self)
            }.onAbandon {
                workflowAbandoned.fulfill()
            }.onFinish { _ in
                XCTFail("Complete should not have been called")
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowItem()

        let secondaryButton = try launcher.find(SecondaryButton.self) // ToS sould have a secondary call to decline
        XCTAssertEqual(try secondaryButton.find(ViewType.Text.self).string(), "Decline")
        XCTAssertNoThrow(try secondaryButton.find(ViewType.Button.self).tap())

        wait(for: [workflowAbandoned], timeout: TestConstant.timeout)
    }
}
