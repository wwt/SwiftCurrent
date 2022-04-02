//
//  MFAViewTests.swift
//  SwiftUIExampleTests
//
//  Created by Tyler Thompson on 7/16/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import ViewInspector

@testable import SwiftCurrent_SwiftUI
@testable import SwiftUIExample

final class MFAViewTests: XCTestCase {
    func testMFAView() async throws {
        let view = try await MFAView(with: .none).hostAndInspect(with: \.inspection)

        XCTAssertEqual(try view.find(ViewType.Text.self, traversal: .depthFirst).string(),
                       "This is your friendly MFA Assistant! Tap the button below to pretend to send a push notification and require an account code")
        XCTAssertEqual(try view.find(ViewType.Button.self).labelView().text().string(), "Start MFA")
    }

    func testMFAViewAllowsCodeInput() async throws {
        let view = try await MFAView(with: .none).hostAndInspect(with: \.inspection)

        XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
        XCTAssertEqual(try view.find(ViewType.Text.self).string(), "Code (enter 1234 to proceed)")
        XCTAssertNoThrow(try view.find(ViewType.TextField.self).setInput("1111"))
    }

    func testMFAViewShowsAlertWhenCodeIsWrong() async throws {
        let view = try await MFAView(with: .none).hostAndInspect(with: \.inspection)

        XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
        XCTAssertEqual(try view.find(ViewType.Text.self).string(), "Code (enter 1234 to proceed)")
        XCTAssertNoThrow(try view.find(ViewType.TextField.self).setInput("1111"))
        XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
        XCTAssertEqual(try view.find(ViewType.Alert.self).title().string(), "Invalid code entered, abandoning workflow.")
    }

    func testMFAViewViewProceedsWithCorrectDataWhenCorrectMFACodeEntered() async throws {
        class CustomObj { }
        let ref = CustomObj()
        let proceedCalled = expectation(description: "Proceed called")
        let erased = AnyFlowRepresentableView(type: MFAView.self, args: .args(ref))
        // swiftlint:disable:next force_cast
        var mfaView = erased.underlyingInstance as! MFAView
        mfaView.proceedInWorkflowStorage = {
            XCTAssert(($0.extractArgs(defaultValue: nil) as? CustomObj) === ref)
            proceedCalled.fulfill()
        }
        mfaView._workflowPointer = erased

        let view = try await mfaView.hostAndInspect(with: \.inspection)

        XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
        XCTAssertEqual(try view.find(ViewType.Text.self).string(), "Code (enter 1234 to proceed)")
        XCTAssertNoThrow(try view.find(ViewType.TextField.self).setInput("1234"))
        XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())

        wait(for: [proceedCalled], timeout: TestConstant.timeout)
    }
}
