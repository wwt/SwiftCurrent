//
//  MFAViewTests.swift
//  SwiftUIExampleTests
//
//  Created by Tyler Thompson on 7/16/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import ViewInspector

import SwiftCurrent_Testing
@testable import SwiftCurrent_SwiftUI
@testable import SwiftUIExample

final class MFAViewTests: XCTestCase {
    func testMFAView() throws {
        let exp = ViewHosting.loadView(MFAView(with: .none)).inspection.inspect { view in
            XCTAssertEqual(try view.find(ViewType.Text.self, traversal: .depthFirst).string(),
                           "This is your friendly MFA Assistant! Tap the button below to pretend to send a push notification and require an account code")
            XCTAssertEqual(try view.find(ViewType.Button.self).labelView().text().string(), "Start MFA")
        }
        wait(for: [exp], timeout: TestConstant.timeout)
    }

    func testMFAViewAllowsCodeInput() throws {
        let exp = ViewHosting.loadView(MFAView(with: .none)).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
            XCTAssertEqual(try view.find(ViewType.Text.self).string(), "Code (enter 1234 to proceed): ")
            XCTAssertNoThrow(try view.find(ViewType.TextField.self).setInput("1111"))
        }
        wait(for: [exp], timeout: TestConstant.timeout)
    }

    func testMFAViewShowsAlertWhenCodeIsWrong() throws {
        let exp = ViewHosting.loadView(MFAView(with: .none)).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
            XCTAssertEqual(try view.find(ViewType.Text.self).string(), "Code (enter 1234 to proceed): ")
            XCTAssertNoThrow(try view.vStack().textField(1).setInput("1111"))
            XCTAssertNoThrow(try view.vStack().button(2).tap())
            XCTAssertEqual(try view.find(ViewType.Alert.self).title().string(), "Invalid code entered, abandoning workflow.")
        }
        wait(for: [exp], timeout: TestConstant.timeout)
    }

    func testMFAViewViewProceedsWithCorrectDataWhenCorrectMFACodeEntered() {
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
        let exp = ViewHosting.loadView(mfaView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())
            XCTAssertEqual(try view.find(ViewType.Text.self).string(), "Code (enter 1234 to proceed): ")
            XCTAssertNoThrow(try view.vStack().textField(1).setInput("1234"))
            XCTAssertNoThrow(try view.vStack().button(2).tap())
        }
        wait(for: [exp, proceedCalled], timeout: TestConstant.timeout)
    }
}
