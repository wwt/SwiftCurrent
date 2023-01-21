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
import SnapshotTesting

@testable import ViewInspector
@testable import SwiftCurrent_SwiftUI // testable sadly needed for inspection.inspect to work

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension InspectableView where View == ViewType.Sheet {
    func isPresented() throws -> Bool {
        (Mirror(reflecting: content.view).descendant("presenter", "isPresented") as? Binding<Bool>)?.wrappedValue ?? false
    }
}

#warning("Tests temporarily disabled as I have no idea how to find modal modifier currently")

@available(iOS 15.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class SwiftCurrent_ModalTests: XCTestCase, Scene {
    @MainActor func testWorkflowCanBeFollowed() async throws {
        struct FR1: View {
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View {
            var body: some View { Text("FR2 type") }
        }
        let expectOnFinish = expectation(description: "OnFinish called")
        let workflowView = try await MainActor.run {
            TestableWorkflowView {
                WorkflowItem { FR1() }.presentationType(.modal)
                WorkflowItem { FR2() }
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
        }
        .hostAndInspect(with: \.inspection)

        let wfr1 = try await workflowView.extractWorkflowItemWrapper()

        XCTAssertEqual(try wfr1.find(FR1.self).text().string(), "FR1 type")
        try await wfr1.proceedInWorkflow()
        XCTAssertNoThrow(try wfr1.find(ViewType.Sheet.self))
        let wfr2 = try await wfr1.extractWrappedWrapper()
        let fr2 = try wfr2.find(FR2.self)
        XCTAssertEqual(try fr2.text().string(), "FR2 type")

        try await wfr2.onFinish { try workflowView.actualView().finish($0) }
            .proceedInWorkflow()

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    @MainActor func testWorkflowCanBeFollowed_WithWorkflowGroup() async throws {
        struct FR1: View {
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View {
            var body: some View { Text("FR2 type") }
        }
        let expectOnFinish = expectation(description: "OnFinish called")

        let workflowView = try await MainActor.run {
            TestableWorkflowView {
                WorkflowItem { FR1() }
                WorkflowGroup {
                    WorkflowItem { FR2() }.presentationType(.modal)
                }
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
        }
        .hostAndInspect(with: \.inspection)

        let wfr1 = try await workflowView.extractWorkflowItemWrapper()

        XCTAssertEqual(try wfr1.find(FR1.self).text().string(), "FR1 type")
        try await wfr1.proceedInWorkflow()
        XCTAssertNoThrow(try wfr1.find(ViewType.Sheet.self))
        let wfr2 = try await wfr1.extractWrappedWrapper()
        let fr2 = try wfr2.find(FR2.self)
        XCTAssertEqual(try fr2.text().string(), "FR2 type")

        try await wfr2.onFinish { try workflowView.actualView().finish($0) }
            .proceedInWorkflow()

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }
//
//    func testWorkflowCanBeFollowed_WithOptionalWorkflowItem_WhenTrue() async throws {
//        struct FR1: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR1 type") }
//        }
//        struct FR2: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR2 type") }
//        }
//        let expectOnFinish = expectation(description: "OnFinish called")
//        let wfr1 = try await MainActor.run {
//            TestableWorkflowView {
//                WorkflowItem { FR1() }
//                if true {
//                    WorkflowItem { FR2() }.presentationType(.modal)
//                }
//            }
//            .onFinish { _ in
//                expectOnFinish.fulfill()
//            }
//        }
//        .hostAndInspect(with: \.inspection)
//        .extractWorkflowLauncher()
//        .extractWorkflowItemWrapper()
//
//        XCTAssertEqual(try wfr1.find(FR1.self).text().string(), "FR1 type")
//        XCTAssertNoThrow(try wfr1.findModalModifier())
//        XCTAssertNoThrow(try wfr1.find(FR1.self))
//try await wfr1.proceedInWorkflow()
//        let wfr2 = try await wfr1.extractWrappedWrapper()
//
//        let fr2 = try wfr2.find(FR2.self)
//        XCTAssertEqual(try fr2.text().string(), "FR2 type")
//        try await fr2.proceedInWorkflow()
//
//        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
//    }
//
//    func testWorkflowCanBeFollowed_WithEitherWorkflowItem_WhenTrue() async throws {
//        struct FR1: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR1 type") }
//        }
//        struct FR2: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR2 type") }
//        }
//        struct FR3: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR3 type") }
//        }
//        let expectOnFinish = expectation(description: "OnFinish called")
//        let wfr1 = try await MainActor.run {
//            TestableWorkflowView {
//                WorkflowItem { FR1() }
//                if true {
//                    WorkflowItem { FR2() }.presentationType(.modal)
//                } else {
//                    WorkflowItem { FR3() }.presentationType(.modal)
//                }
//            }
//            .onFinish { _ in
//                expectOnFinish.fulfill()
//            }
//        }
//        .hostAndInspect(with: \.inspection)
//        .extractWorkflowLauncher()
//        .extractWorkflowItemWrapper()
//
//        XCTAssertEqual(try wfr1.find(FR1.self).text().string(), "FR1 type")
//        XCTAssertNoThrow(try wfr1.findModalModifier())
//        XCTAssertNoThrow(try wfr1.find(FR1.self))
//try await wfr1.proceedInWorkflow()
//        let wfr2 = try await wfr1.extractWrappedWrapper()
//
//        let fr2 = try wfr2.find(FR2.self)
//        XCTAssertEqual(try fr2.text().string(), "FR2 type")
//        try await fr2.proceedInWorkflow()
//
//        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
//    }
//
//    func testWorkflowCanBeFollowed_WithEitherWorkflowItem_WhenFalse() async throws {
//        struct FR1: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR1 type") }
//        }
//        struct FR2: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR2 type") }
//        }
//        struct FR3: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR3 type") }
//        }
//        let expectOnFinish = expectation(description: "OnFinish called")
//        let wfr1 = try await MainActor.run {
//            TestableWorkflowView {
//                WorkflowItem { FR1() }
//                if false {
//                    WorkflowItem { FR2() }.presentationType(.modal)
//                } else {
//                    WorkflowItem { FR3() }.presentationType(.modal)
//                }
//            }
//            .onFinish { _ in
//                expectOnFinish.fulfill()
//            }
//        }
//        .hostAndInspect(with: \.inspection)
//        .extractWorkflowLauncher()
//        .extractWorkflowItemWrapper()
//
//        XCTAssertEqual(try wfr1.find(FR1.self).text().string(), "FR1 type")
//        XCTAssertNoThrow(try wfr1.findModalModifier())
//        XCTAssertNoThrow(try wfr1.find(FR1.self))
//try await wfr1.proceedInWorkflow()
//        let wfr2 = try await wfr1.extractWrappedWrapper()
//
//        let fr3 = try wfr2.find(FR3.self)
//        XCTAssertEqual(try fr3.text().string(), "FR3 type")
//        try await fr3.proceedInWorkflow()
//
//        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
//    }
//
//    func testWorkflowItemsOfTheSameTypeCanBeFollowed() async throws {
//        struct FR1: View {
//            var body: some View { Text("FR1 type") }
//        }
//
//        let wfr1 = try await MainActor.run {
//            TestableWorkflowView {
//                WorkflowItem { FR1() }
//                WorkflowItem { FR1() }.presentationType(.modal)
//                WorkflowItem { FR1() }.presentationType(.modal)
//            }
//        }
//        .hostAndInspect(with: \.inspection)
//        .extractWorkflowLauncher()
//        .extractWorkflowItemWrapper()
//
//        XCTAssertNoThrow(try wfr1.findModalModifier())
//        XCTAssertNoThrow(try wfr1.find(FR1.self))
//try await wfr1.proceedInWorkflow()
//
//        let wfr2 = try await wfr1.extractWrappedWrapper()
//        XCTAssertNoThrow(try wfr2.findModalModifier())
//        XCTAssertNoThrow(try wfr2.find(FR1.self))
//try await wfr2.proceedInWorkflow()
//
//        let wfr3 = try await wfr2.extractWrappedWrapper()
//        XCTAssertNoThrow(try wfr3.find(FR1.self))
//try await wfr3.proceedInWorkflow()
//    }
//
//    func testLargeWorkflowCanBeFollowed() async throws {
//        struct FR1: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR1 type") }
//        }
//        struct FR2: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR2 type") }
//        }
//        struct FR3: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR3 type") }
//        }
//        struct FR4: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR4 type") }
//        }
//        struct FR5: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR5 type") }
//        }
//        struct FR6: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR6 type") }
//        }
//        struct FR7: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR7 type") }
//        }
//
//        let wfr1 = try await MainActor.run {
//            TestableWorkflowView {
//                WorkflowItem { FR1() }.presentationType(.modal)
//                WorkflowItem { FR2() }.presentationType(.modal)
//                WorkflowItem { FR3() }.presentationType(.modal)
//                WorkflowItem { FR4() }.presentationType(.modal)
//                WorkflowItem { FR5() }.presentationType(.modal)
//                WorkflowItem { FR6() }.presentationType(.modal)
//                WorkflowItem { FR7() }.presentationType(.modal)
//            }
//        }
//        .hostAndInspect(with: \.inspection)
//        .extractWorkflowLauncher()
//        .extractWorkflowItemWrapper()
//
//        XCTAssertNoThrow(try wfr1.findModalModifier())
//        XCTAssertNoThrow(try wfr1.find(FR1.self))
//try await wfr1.proceedInWorkflow()
//
//        let wfr2 = try await wfr1.extractWrappedWrapper()
//        XCTAssertNoThrow(try wfr2.findModalModifier())
//        XCTAssertNoThrow(try wfr2.find(FR2.self))
//try await wfr2.proceedInWorkflow()
//
//        let wfr3 = try await wfr2.extractWrappedWrapper()
//        XCTAssertNoThrow(try wfr3.findModalModifier())
//        XCTAssertNoThrow(try wfr3.find(FR3.self))
//try await wfr3.proceedInWorkflow()
//
//        let wfr4 = try await wfr3.extractWrappedWrapper()
//        XCTAssertNoThrow(try wfr4.findModalModifier())
//        XCTAssertNoThrow(try wfr4.find(FR4.self))
//try await wfr4.proceedInWorkflow()
//
//        let wfr5 = try await wfr4.extractWrappedWrapper()
//        XCTAssertNoThrow(try wfr5.findModalModifier())
//        XCTAssertNoThrow(try wfr5.find(FR5.self))
//try await wfr5.proceedInWorkflow()
//
//        let wfr6 = try await wfr5.extractWrappedWrapper()
//        XCTAssertNoThrow(try wfr6.findModalModifier())
//        XCTAssertNoThrow(try wfr6.find(FR6.self))
//try await wfr6.proceedInWorkflow()
//
//        let wfr7 = try await wfr6.extractWrappedWrapper()
//        XCTAssertNoThrow(try wfr7.find(FR7.self))
//try await wfr7.proceedInWorkflow()
//    }
//
//    func testNavLinkWorkflowsCanSkipTheFirstItem() async throws {
//        struct FR1: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR1 type") }
//            func shouldLoad() -> Bool { false }
//        }
//        struct FR2: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR2 type") }
//        }
//        struct FR3: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR3 type") }
//        }
//        let wfr1 = try await MainActor.run {
//            TestableWorkflowView {
//                WorkflowItem { FR1() }
//                WorkflowItem { FR2() }.presentationType(.modal)
//                WorkflowItem { FR3() }.presentationType(.modal)
//            }
//        }
//        .hostAndInspect(with: \.inspection)
//        .extractWorkflowLauncher()
//        .extractWorkflowItemWrapper()
//
//        XCTAssertThrowsError(try wfr1.find(FR1.self))
//
//        let wfr2 = try await wfr1.extractWrappedWrapper()
//        XCTAssertNoThrow(try wfr2.findModalModifier())
//        XCTAssertNoThrow(try wfr2.find(FR2.self))
//try await wfr2.proceedInWorkflow()
//
//        let wfr3 = try await wfr2.extractWrappedWrapper()
//        XCTAssertNoThrow(try wfr3.find(FR3.self))
//try await wfr3.proceedInWorkflow()
//    }
//
//    func testNavLinkWorkflowsCanSkipOneItemInTheMiddle() async throws {
//        struct FR1: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR1 type") }
//        }
//        struct FR2: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR2 type") }
//            func shouldLoad() -> Bool { false }
//        }
//        struct FR3: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR3 type") }
//        }
//
//        let wfr1 = try await MainActor.run {
//            TestableWorkflowView {
//                WorkflowItem { FR1() }
//                WorkflowItem { FR2() }.presentationType(.modal)
//                WorkflowItem { FR3() }.presentationType(.modal)
//            }
//        }
//        .hostAndInspect(with: \.inspection)
//        .extractWorkflowLauncher()
//        .extractWorkflowItemWrapper()
//
//        XCTAssertNoThrow(try wfr1.findModalModifier())
//        XCTAssertNoThrow(try wfr1.find(FR1.self))
//try await wfr1.proceedInWorkflow()
//
//        let wfr2 = try await wfr1.extractWrappedWrapper()
//        XCTAssertThrowsError(try wfr2.find(FR2.self))
//
//        let wfr3 = try await wfr2.extractWrappedWrapper()
//        XCTAssertNoThrow(try wfr3.find(FR3.self))
//try await wfr3.proceedInWorkflow()
//    }
//
//    func testNavLinkWorkflowsCanSkipTwoItemsInTheMiddle() async throws {
//        struct FR1: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR1 type") }
//        }
//        struct FR2: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR2 type") }
//            func shouldLoad() -> Bool { false }
//        }
//        struct FR3: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR3 type") }
//            func shouldLoad() -> Bool { false }
//        }
//        struct FR4: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR3 type") }
//        }
//
//        let wfr1 = try await MainActor.run {
//            TestableWorkflowView {
//                WorkflowItem { FR1() }
//                WorkflowItem { FR2() }.presentationType(.modal)
//                WorkflowItem { FR3() }.presentationType(.modal)
//                WorkflowItem { FR4() }.presentationType(.modal)
//            }
//        }
//        .hostAndInspect(with: \.inspection)
//        .extractWorkflowLauncher()
//        .extractWorkflowItemWrapper()
//
//        XCTAssertNoThrow(try wfr1.findModalModifier())
//        XCTAssertNoThrow(try wfr1.find(FR1.self))
//try await wfr1.proceedInWorkflow()
//
//        let wfr2 = try await wfr1.extractWrappedWrapper()
//        XCTAssertThrowsError(try wfr2.find(FR2.self))
//
//        let wfr3 = try await wfr2.extractWrappedWrapper()
//        XCTAssertThrowsError(try wfr3.find(FR3.self))
//
//        let wfr4 = try await wfr3.extractWrappedWrapper()
//        XCTAssertNoThrow(try wfr4.find(FR4.self))
//try await wfr4.proceedInWorkflow()
//    }
//
//    func testNavLinkWorkflowsCanSkipLastItem() async throws {
//        struct FR1: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR1 type") }
//        }
//        struct FR2: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR2 type") }
//        }
//        struct FR3: View, FlowRepresentable, Inspectable {
////            var body: some View { Text("FR3 type") }
//            func shouldLoad() -> Bool { false }
//        }
//
//        let expectOnFinish = expectation(description: "onFinish called")
//        let wfr1 = try await MainActor.run {
//            TestableWorkflowView {
//                WorkflowItem { FR1() }
//                WorkflowItem { FR2() }.presentationType(.modal)
//                WorkflowItem { FR3() }.presentationType(.modal)
//            }
//            .onFinish { _ in
//                expectOnFinish.fulfill()
//            }
//        }
//        .hostAndInspect(with: \.inspection)
//        .extractWorkflowLauncher()
//        .extractWorkflowItemWrapper()
//
//        XCTAssertNoThrow(try wfr1.findModalModifier())
//        XCTAssertNoThrow(try wfr1.find(FR1.self))
//try await wfr1.proceedInWorkflow()
//
//        let wfr2 = try await wfr1.extractWrappedWrapper()
//        XCTAssertNoThrow(try wfr2.findModalModifier())
//        XCTAssertNoThrow(try wfr2.find(FR2.self))
//try await wfr2.proceedInWorkflow()
//        XCTAssertThrowsError(try wfr2.find(FR3.self))
//
//        let wfr3 = try await wfr2.extractWrappedWrapper()
//        XCTAssertThrowsError(try wfr3.find(FR3.self))
//
//        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
//    }
}
