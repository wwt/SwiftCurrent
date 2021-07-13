//
//  SwiftCurrent_SwiftUIConsumerTests.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 7/12/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import SwiftUI

import SwiftCurrent
import SwiftCurrent_SwiftUI
import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class SwiftCurrent_SwiftUIConsumerTests: XCTestCase {
    func testWorkflowCanBeFollowed() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }
        let expectOnFinish = expectation(description: "OnFinish called")
        let viewUnderTest = WorkflowView(isPresented: .constant(true))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self))
            .onFinish {
                expectOnFinish.fulfill()
            }

        XCTAssertEqual(try viewUnderTest.inspect().anyView().view(FR1.self).text().string(), "FR1 type")
        XCTAssertNoThrow(try viewUnderTest.inspect().anyView().view(FR1.self).actualView().proceedInWorkflow())
        XCTAssertEqual(try viewUnderTest.inspect().anyView().view(FR2.self).text().string(), "FR2 type")
        XCTAssertNoThrow(try viewUnderTest.inspect().anyView().view(FR2.self).actualView().proceedInWorkflow())

        wait(for: [expectOnFinish], timeout: 0.3)
    }
}
