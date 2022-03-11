//
//  ChangeUsernameViewTests.swift
//  SwiftUIExampleTests
//
//  Created by Tyler Thompson on 7/16/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import ViewInspector

@testable import SwiftCurrent_SwiftUI
@testable import SwiftUIExample

final class ChangeUsernameViewTests: XCTestCase {
    func testChangeUsernameView() async throws {
        let currentUsername = UUID().uuidString
        let view = try await ChangeEmailView(with: currentUsername).hostAndInspect(with: \.inspection)

        XCTAssertEqual(try view.find(ViewType.Text.self, traversal: .depthFirst).string(), "New email: ")
        XCTAssertEqual(try view.find(ViewType.TextField.self).labelView().text().string(), "\(currentUsername)")
        XCTAssertNoThrow(try view.find(ViewType.Button.self))
    }

    func testChangeUsernameViewProceedsWithCorrectDataWhenNameChanged() async throws {
        let newUsername = UUID().uuidString
        let proceedCalled = expectation(description: "Proceed called")
        let erased = AnyFlowRepresentableView(type: ChangeEmailView.self, args: .args(""))
        // swiftlint:disable:next force_cast
        var changeUsernameView = erased.underlyingInstance as! ChangeEmailView
        changeUsernameView.proceedInWorkflowStorage = {
            XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, newUsername)
            proceedCalled.fulfill()
        }
        changeUsernameView._workflowPointer = erased
        let view = try await changeUsernameView.hostAndInspect(with: \.inspection)

        XCTAssertEqual(try view.find(ViewType.Text.self, traversal: .depthFirst).string(), "New email: ")
        XCTAssertNoThrow(try view.find(ViewType.TextField.self).setInput(newUsername))
        XCTAssertNoThrow(try view.find(ViewType.Button.self).tap())

        wait(for: [proceedCalled], timeout: TestConstant.timeout)
    }
}
