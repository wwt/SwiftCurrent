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
    func testLayout() {
        let exp = ViewHosting.loadView(TermsAndConditions()).inspection.inspect { view in
            XCTAssertEqual(view.findAll(ViewType.Button.self).count, 2)
        }
        wait(for: [exp], timeout: TestConstant.timeout)
    }

    func testPrimaryAcceptButtonCompletesWorkflow() {
        let workflowFinished = expectation(description: "View Proceeded")
        let exp = ViewHosting.loadView(WorkflowLauncher(isLaunched: .constant(true)) {
            thenProceed(with: TermsAndConditions.self)
        }.onAbandon {
            XCTFail("Abandon should not have been called")
        }.onFinish { _ in
            workflowFinished.fulfill()
        }).inspection.inspect { view in
            let primaryButton = try view.find(PrimaryButton.self) // ToS should have a primary call to accept
            XCTAssertEqual(try primaryButton.find(ViewType.Text.self).string(), "Accept")
            XCTAssertNoThrow(try primaryButton.find(ViewType.Button.self).tap())
        }
        wait(for: [exp, workflowFinished], timeout: TestConstant.timeout)
    }

    func testSecondaryRejectButtonAbandonsWorkflow() {
        let workflowAbandoned = expectation(description: "View Proceeded")
        let exp = ViewHosting.loadView(WorkflowLauncher(isLaunched: .constant(true)) {
            thenProceed(with: TermsAndConditions.self)
        }.onAbandon {
            workflowAbandoned.fulfill()
        }.onFinish { _ in
            XCTFail("Complete should not have been called")
        }).inspection.inspect { view in
            let secondaryButton = try view.find(SecondaryButton.self) // ToS sould have a secondary call to decline
            XCTAssertEqual(try secondaryButton.find(ViewType.Text.self).string(), "Decline")
            XCTAssertNoThrow(try secondaryButton.find(ViewType.Button.self).tap())
        }
        wait(for: [exp, workflowAbandoned], timeout: TestConstant.timeout)
    }
}
