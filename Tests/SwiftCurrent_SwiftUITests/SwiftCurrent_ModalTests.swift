//
//  SwiftCurrent_ModalTests.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 7/12/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import SwiftUI

import SwiftCurrent

@testable import ViewInspector
@testable import SwiftCurrent_SwiftUI // testable sadly needed for inspection.inspect to work

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension InspectableView where View == ViewType.Sheet {
    func isPresented() throws -> Bool {
        (Mirror(reflecting: content.view).descendant("presenter", "isPresented") as? Binding<Bool>)?.wrappedValue ?? false
    }
}

@available(iOS 15.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class SwiftCurrent_ModalTests: XCTestCase, Scene {
    func testModalModifier() throws {
        let sampleView = Text("Test")
        let binding = Binding(wrappedValue: true)
        let viewUnderTest = try sampleView.modal(isPresented: binding, style: .sheet, destination: Text("nextView")).inspect()
        XCTAssertNoThrow(try viewUnderTest.sheet())
        XCTAssert(try viewUnderTest.sheet().isPresented())
        XCTAssertEqual(try viewUnderTest.sheet().text().string(), "nextView")
        binding.wrappedValue = false
        XCTAssertThrowsError(try viewUnderTest.sheet())
    }

    func testWorkflowCanBeFollowed() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }
        let expectOnFinish = expectation(description: "OnFinish called")
        let wfr1 = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self).presentationType(.modal)
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        XCTAssertEqual(try wfr1.find(FR1.self).text().string(), "FR1 type")
        XCTAssertNoThrow(try wfr1.findModalModifier())
        try await wfr1.find(FR1.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWrapper()

        let fr2 = try wfr2.find(FR2.self)
        XCTAssertEqual(try fr2.text().string(), "FR2 type")
        try await fr2.proceedInWorkflow()

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    func testWorkflowItemsOfTheSameTypeCanBeFollowed() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }

        let wfr1 = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR1.self).presentationType(.modal)
                WorkflowItem(FR1.self).presentationType(.modal)
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        XCTAssertNoThrow(try wfr1.findModalModifier())
        try await wfr1.find(FR1.self).proceedInWorkflow()

        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.findModalModifier())
        try await wfr2.find(FR1.self).proceedInWorkflow()

        let wfr3 = try await wfr2.extractWrappedWrapper()
        try await wfr3.find(FR1.self).proceedInWorkflow()
    }

    func testLargeWorkflowCanBeFollowed() async throws {
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
        }
        struct FR5: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR5 type") }
        }
        struct FR6: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR6 type") }
        }
        struct FR7: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR7 type") }
        }

        let wfr1 = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self).presentationType(.modal)
                WorkflowItem(FR2.self).presentationType(.modal)
                WorkflowItem(FR3.self).presentationType(.modal)
                WorkflowItem(FR4.self).presentationType(.modal)
                WorkflowItem(FR5.self).presentationType(.modal)
                WorkflowItem(FR6.self).presentationType(.modal)
                WorkflowItem(FR7.self).presentationType(.modal)
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        XCTAssertNoThrow(try wfr1.findModalModifier())
        try await wfr1.find(FR1.self).proceedInWorkflow()

        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.findModalModifier())
        try await wfr2.find(FR2.self).proceedInWorkflow()

        let wfr3 = try await wfr2.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr3.findModalModifier())
        try await wfr3.find(FR3.self).proceedInWorkflow()

        let wfr4 = try await wfr3.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr4.findModalModifier())
        try await wfr4.find(FR4.self).proceedInWorkflow()

        let wfr5 = try await wfr4.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr5.findModalModifier())
        try await wfr5.find(FR5.self).proceedInWorkflow()

        let wfr6 = try await wfr5.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr6.findModalModifier())
        try await wfr6.find(FR6.self).proceedInWorkflow()

        let wfr7 = try await wfr6.extractWrappedWrapper()
        try await wfr7.find(FR7.self).proceedInWorkflow()
    }

    func testNavLinkWorkflowsCanSkipTheFirstItem() async throws {
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
        let wfr1 = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self).presentationType(.modal)
                WorkflowItem(FR3.self).presentationType(.modal)
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        XCTAssertThrowsError(try wfr1.find(FR1.self))
        #warning("Do we need this?")
        XCTAssertNoThrow(try wfr1.find(FR2.self))

        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.findModalModifier())
        try await wfr2.find(FR2.self).proceedInWorkflow()

        let wfr3 = try await wfr2.extractWrappedWrapper()
        try await wfr3.find(FR3.self).proceedInWorkflow()
    }

    func testNavLinkWorkflowsCanSkipOneItemInTheMiddle() async throws {
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

        let wfr1 = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self).presentationType(.modal)
                WorkflowItem(FR3.self).presentationType(.modal)
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        XCTAssertNoThrow(try wfr1.findModalModifier())
        try await wfr1.find(FR1.self).proceedInWorkflow()

        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertThrowsError(try wfr2.find(FR2.self))
        XCTAssertNoThrow(try wfr2.find(FR3.self))

        let wfr3 = try await wfr2.extractWrappedWrapper()
        try await wfr3.find(FR3.self).proceedInWorkflow()
    }

    func testNavLinkWorkflowsCanSkipTwoItemsInTheMiddle() async throws {
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
            var body: some View { Text("FR3 type") }
        }

        let wfr1 = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self).presentationType(.modal)
                WorkflowItem(FR3.self).presentationType(.modal)
                WorkflowItem(FR4.self).presentationType(.modal)
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        XCTAssertNoThrow(try wfr1.findModalModifier())
        try await wfr1.find(FR1.self).proceedInWorkflow()

        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertThrowsError(try wfr2.find(FR2.self))
        XCTAssertNoThrow(try wfr2.find(FR4.self))

        let wfr3 = try await wfr2.extractWrappedWrapper()
        XCTAssertThrowsError(try wfr3.find(FR3.self))
        XCTAssertNoThrow(try wfr3.find(FR4.self))

        let wfr4 = try await wfr3.extractWrappedWrapper()
        try await wfr4.find(FR4.self).proceedInWorkflow()
    }

    func testNavLinkWorkflowsCanSkipLastItem() async throws {
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
            func shouldLoad() -> Bool { false }
        }

        let expectOnFinish = expectation(description: "onFinish called")
        let wfr1 = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self).presentationType(.modal)
                WorkflowItem(FR3.self).presentationType(.modal)
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        XCTAssertNoThrow(try wfr1.findModalModifier())
        try await wfr1.find(FR1.self).proceedInWorkflow()

        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.findModalModifier())
        try await wfr2.find(FR2.self).proceedInWorkflow()
        XCTAssertThrowsError(try wfr2.find(FR3.self))

        let wfr3 = try await wfr2.extractWrappedWrapper()
        XCTAssertThrowsError(try wfr3.find(FR3.self))

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }
}
