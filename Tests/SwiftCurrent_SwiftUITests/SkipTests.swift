//
//  SkipTests.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 7/12/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import SwiftUI
import ViewInspector

import SwiftCurrent
@testable import SwiftCurrent_SwiftUI // testable sadly needed for inspection.inspect to work

@available(iOS 15.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class SkipTests: XCTestCase, View {
    func testSkippingFirstItemInAWorkflow() async throws {
        // NOTE: Workflows in the past had issues with 4+ items, so this is to cover our bases. SwiftUI also has a nasty habit of behaving a little differently as number of views increase.
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
            func shouldLoad() -> Bool { false }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }
        struct FR3: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR3 type") }
        }
        struct FR4: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR4 type") }
        }
        let launcher = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self) {
                            thenProceed(with: FR4.self)
                        }
                    }
                }
            }
        }.hostAndInspect(with: \.inspection)

        XCTAssertThrowsError(try launcher.find(FR1.self))
        try await launcher.find(FR2.self).proceedInWorkflow()
        try await launcher.find(FR3.self).proceedInWorkflow()
        try await launcher.find(FR4.self).proceedInWorkflow()
    }

    func testSkippingMiddleItemInAWorkflow() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
            func shouldLoad() -> Bool { false }
        }
        struct FR3: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR3 type") }
        }
        struct FR4: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR4 type") }
        }
        let launcher = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self) {
                            thenProceed(with: FR4.self)
                        }
                    }
                }
            }
        }.hostAndInspect(with: \.inspection)

        try await launcher.find(FR1.self).proceedInWorkflow()
        XCTAssertThrowsError(try launcher.find(FR2.self))
        try await launcher.find(FR3.self).proceedInWorkflow()
        try await launcher.find(FR4.self).proceedInWorkflow()
    }

    func testSkippingLastItemInAWorkflow() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }
        struct FR3: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR3 type") }
        }
        struct FR4: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR4 type") }
            func shouldLoad() -> Bool { false }
        }
        let expectOnFinish = expectation(description: "OnFinish called")
        let launcher = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self) {
                            thenProceed(with: FR4.self)
                        }
                    }
                }
            }
            .onFinish { _ in expectOnFinish.fulfill() }
        }.hostAndInspect(with: \.inspection)

        try await launcher.find(FR1.self).proceedInWorkflow()
        try await launcher.find(FR2.self).proceedInWorkflow()
        try await launcher.find(FR3.self).proceedInWorkflow()
        XCTAssertThrowsError(try launcher.find(FR4.self))
        XCTAssertNoThrow(try launcher.find(FR3.self))

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    func testSkippingMultipleItemsInAWorkflow() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
            func shouldLoad() -> Bool { false }
        }
        struct FR3: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR3 type") }
            func shouldLoad() -> Bool { false }
        }
        struct FR4: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR4 type") }
        }
        let launcher = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self) {
                            thenProceed(with: FR4.self)
                        }
                    }
                }
            }
        }.hostAndInspect(with: \.inspection)

        try await launcher.find(FR1.self).proceedInWorkflow()
        XCTAssertThrowsError(try launcher.find(FR2.self).actualView())
        XCTAssertThrowsError(try launcher.find(FR3.self).actualView())
        try await launcher.find(FR4.self).proceedInWorkflow()
    }

    func testSkippingAllItemsInAWorkflow() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
            func shouldLoad() -> Bool { false }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
            func shouldLoad() -> Bool { false }
        }
        struct FR3: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR3 type") }
            func shouldLoad() -> Bool { false }
        }
        struct FR4: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR4 type") }
            func shouldLoad() -> Bool { false }
        }
        let expectOnFinish = expectation(description: "OnFinish called")
        let launcher = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self) {
                            thenProceed(with: FR4.self)
                        }
                    }
                }
            }
            .onFinish { _ in expectOnFinish.fulfill() }
        }.hostAndInspect(with: \.inspection)

        XCTAssertThrowsError(try launcher.find(FR1.self))
        XCTAssertThrowsError(try launcher.find(FR2.self))
        XCTAssertThrowsError(try launcher.find(FR3.self))
        XCTAssertThrowsError(try launcher.find(FR4.self))

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }
}
