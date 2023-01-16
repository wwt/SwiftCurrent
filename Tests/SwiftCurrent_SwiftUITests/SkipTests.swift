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
        struct FR1: View {
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View {
            var body: some View { Text("FR2 type") }
        }
        struct FR3: View {
            var body: some View { Text("FR3 type") }
        }
        struct FR4: View {
            var body: some View { Text("FR4 type") }
        }
        let workflowView = try await MainActor.run {
            TestableWorkflowView {
                WorkflowItem { FR1() }.shouldLoad(false)
                WorkflowItem { FR2() }
                WorkflowItem { FR3() }
                WorkflowItem { FR4() }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItemWrapper()

        XCTAssertThrowsError(try workflowView.find(FR1.self))
        XCTAssertNoThrow(try workflowView.find(FR2.self))
        let wfr2 = try await workflowView.extractWrappedWrapper()
        try await wfr2.proceedInWorkflow()
        let wfr3 = try await wfr2.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr3.find(FR3.self))
        try await wfr3.proceedInWorkflow()
        let wfr4 = try await wfr3.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr4.find(FR4.self))
    }

    func testSkippingMiddleItemInAWorkflow() async throws {
        struct FR1: View {
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View {
            var body: some View { Text("FR2 type") }
        }
        struct FR3: View {
            var body: some View { Text("FR3 type") }
        }
        struct FR4: View {
            var body: some View { Text("FR4 type") }
        }
        let workflowView = try await MainActor.run {
            TestableWorkflowView {
                WorkflowItem { FR1() }
                WorkflowItem { FR2() }.shouldLoad(false)
                WorkflowItem { FR3() }
                WorkflowItem { FR4() }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItemWrapper()

        XCTAssertNoThrow(try workflowView.find(FR1.self))
        try await workflowView.proceedInWorkflow()
        let wfr2 = try await workflowView.extractWrappedWrapper()
        XCTAssertThrowsError(try wfr2.find(FR2.self))
        let wfr3 = try await wfr2.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr3.find(FR3.self))
        try await wfr3.proceedInWorkflow()
        let wfr4 = try await wfr3.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr4.find(FR4.self))
    }

    func testSkippingLastItemInAWorkflow() async throws {
        struct FR1: View {
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View {
            var body: some View { Text("FR2 type") }
        }
        struct FR3: View {
            var body: some View { Text("FR3 type") }
        }
        struct FR4: View {
            var body: some View { Text("FR4 type") }
        }
        let expectOnFinish = expectation(description: "OnFinish called")
        let workflowView = try await MainActor.run {
            TestableWorkflowView {
                WorkflowItem { FR1() }
                WorkflowItem { FR2() }
                WorkflowItem { FR3() }
                WorkflowItem { FR4() }.shouldLoad(false)
            }
            .onFinish { _ in expectOnFinish.fulfill() }
        }.hostAndInspect(with: \.inspection).extractWorkflowItemWrapper()

        XCTAssertNoThrow(try workflowView.find(FR1.self))
        try await workflowView.proceedInWorkflow()
        let wfr2 = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        try await wfr2.proceedInWorkflow()
        let wfr3 = try await wfr2.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr3.find(FR3.self))
        try await wfr3.proceedInWorkflow()
        let wfr4 = try await wfr3.extractWrappedWrapper()
        XCTAssertThrowsError(try wfr4.find(FR4.self))

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    func testSkippingMultipleItemsInAWorkflow() async throws {
        struct FR1: View {
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View {
            var body: some View { Text("FR2 type") }
        }
        struct FR3: View {
            var body: some View { Text("FR3 type") }
        }
        struct FR4: View {
            var body: some View { Text("FR4 type") }
        }
        let workflowView = try await MainActor.run {
            TestableWorkflowView {
                WorkflowItem { FR1() }
                WorkflowItem { FR2() }.shouldLoad(false)
                WorkflowItem { FR3() }.shouldLoad(false)
                WorkflowItem { FR4() }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItemWrapper()

        XCTAssertNoThrow(try workflowView.find(FR1.self))
        try await workflowView.proceedInWorkflow()
        let wfr2 = try await workflowView.extractWrappedWrapper()
        XCTAssertThrowsError(try wfr2.find(FR2.self))
        let wfr3 = try await wfr2.extractWrappedWrapper()
        XCTAssertThrowsError(try wfr3.find(FR3.self))
        let wfr4 = try await wfr3.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr4.find(FR4.self))
    }

    func testSkippingAllItemsInAWorkflow() async throws {
        struct FR1: View {
            var body: some View { Text("FR1 type") }
            func shouldLoad() -> Bool { false }
        }
        struct FR2: View {
            var body: some View { Text("FR2 type") }
            func shouldLoad() -> Bool { false }
        }
        struct FR3: View {
            var body: some View { Text("FR3 type") }
            func shouldLoad() -> Bool { false }
        }
        struct FR4: View {
            var body: some View { Text("FR4 type") }
            func shouldLoad() -> Bool { false }
        }
        let expectOnFinish = expectation(description: "OnFinish called")
        let workflowView = try await MainActor.run {
            TestableWorkflowView {
                WorkflowItem { FR1() }.shouldLoad(false)
                WorkflowItem { FR2() }.shouldLoad(false)
                WorkflowItem { FR3() }.shouldLoad(false)
                WorkflowItem { FR4() }.shouldLoad(false)
            }
            .onFinish { _ in expectOnFinish.fulfill() }
        }.hostAndInspect(with: \.inspection).extractWorkflowItemWrapper()

        XCTAssertThrowsError(try workflowView.find(FR1.self))
        XCTAssertThrowsError(try workflowView.find(FR2.self))
        XCTAssertThrowsError(try workflowView.find(FR3.self))
        XCTAssertThrowsError(try workflowView.find(FR4.self))

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }
}
