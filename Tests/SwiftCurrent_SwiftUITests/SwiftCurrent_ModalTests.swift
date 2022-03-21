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
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self).presentationType(.modal)
                }
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowItem()

        let model = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_model") as? EnvironmentObject<WorkflowViewModel>)?.wrappedValue)
        }
        let launcher = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_launcher") as? EnvironmentObject<Launcher>)?.wrappedValue)
        }

        XCTAssertEqual(try wfr1.find(FR1.self).text().string(), "FR1 type")
        try await wfr1.find(FR1.self).proceedInWorkflow()
        try await wfr1.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssertTrue(try wfr1.find(ViewType.Sheet.self).isPresented())

        let fr2 = try wfr1.find(ViewType.Sheet.self).find(FR2.self)
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
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR1.self).presentationType(.modal)
                    }.presentationType(.modal)
                }
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowItem()

        let model = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_model") as? EnvironmentObject<WorkflowViewModel>)?.wrappedValue)
        }
        let launcher = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_launcher") as? EnvironmentObject<Launcher>)?.wrappedValue)
        }

        try await wfr1.find(FR1.self).proceedInWorkflow()
        try await wfr1.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssertTrue(try wfr1.find(ViewType.Sheet.self).isPresented())

        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        try await wfr2.find(FR1.self).proceedInWorkflow()
        try await wfr2.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssertTrue(try wfr2.find(ViewType.Sheet.self).isPresented())

        let wfr3 = try await wfr2.extractWrappedWorkflowItem()
        try await wfr3.find(FR1.self).proceedInWorkflow()
        try await wfr3.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
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
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self) {
                            thenProceed(with: FR4.self) {
                                thenProceed(with: FR5.self) {
                                    thenProceed(with: FR6.self) {
                                        thenProceed(with: FR7.self).presentationType(.modal)
                                    }.presentationType(.modal)
                                }.presentationType(.modal)
                            }.presentationType(.modal)
                        }.presentationType(.modal)
                    }.presentationType(.modal)
                }
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowItem()

        let model = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_model") as? EnvironmentObject<WorkflowViewModel>)?.wrappedValue)
        }
        let launcher = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_launcher") as? EnvironmentObject<Launcher>)?.wrappedValue)
        }

        try await wfr1.find(FR1.self).proceedInWorkflow()
        try await wfr1.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssertTrue(try wfr1.find(ViewType.Sheet.self).isPresented())

        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        try await wfr2.find(FR2.self).proceedInWorkflow()
        try await wfr2.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssertTrue(try wfr2.find(ViewType.Sheet.self).isPresented())

        let wfr3 = try await wfr2.extractWrappedWorkflowItem()
        try await wfr3.find(FR3.self).proceedInWorkflow()
        try await wfr3.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssertTrue(try wfr3.find(ViewType.Sheet.self).isPresented())

        let wfr4 = try await wfr3.extractWrappedWorkflowItem()
        try await wfr4.find(FR4.self).proceedInWorkflow()
        try await wfr4.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssertTrue(try wfr4.find(ViewType.Sheet.self).isPresented())

        let wfr5 = try await wfr4.extractWrappedWorkflowItem()
        try await wfr5.find(FR5.self).proceedInWorkflow()
        try await wfr5.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssertTrue(try wfr5.find(ViewType.Sheet.self).isPresented())

        let wfr6 = try await wfr5.extractWrappedWorkflowItem()
        try await wfr6.find(FR6.self).proceedInWorkflow()
        try await wfr6.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssertTrue(try wfr6.find(ViewType.Sheet.self).isPresented())

        let wfr7 = try await wfr6.extractWrappedWorkflowItem()
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
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self).presentationType(.modal)
                    }.presentationType(.modal)
                }
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowItem()

        let model = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_model") as? EnvironmentObject<WorkflowViewModel>)?.wrappedValue)
        }
        let launcher = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_launcher") as? EnvironmentObject<Launcher>)?.wrappedValue)
        }

        XCTAssertThrowsError(try wfr1.find(FR1.self))
        XCTAssertNoThrow(try wfr1.find(FR2.self))

        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        try await wfr2.find(FR2.self).proceedInWorkflow()
        try await wfr2.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssertTrue(try wfr2.find(ViewType.Sheet.self).isPresented())

        let wfr3 = try await wfr2.extractWrappedWorkflowItem()
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
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self).presentationType(.modal)
                    }.presentationType(.modal)
                }
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowItem()

        let model = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_model") as? EnvironmentObject<WorkflowViewModel>)?.wrappedValue)
        }
        let launcher = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_launcher") as? EnvironmentObject<Launcher>)?.wrappedValue)
        }

        try await wfr1.find(FR1.self).proceedInWorkflow()
        try await wfr1.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssertTrue(try wfr1.find(ViewType.Sheet.self).isPresented())

        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertThrowsError(try wfr2.find(FR2.self))
        XCTAssertNoThrow(try wfr2.find(FR3.self))

        let wfr3 = try await wfr2.extractWrappedWorkflowItem()
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
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self) {
                            thenProceed(with: FR4.self).presentationType(.modal)
                        }
                    }.presentationType(.modal)
                }
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowItem()

        let model = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_model") as? EnvironmentObject<WorkflowViewModel>)?.wrappedValue)
        }
        let launcher = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_launcher") as? EnvironmentObject<Launcher>)?.wrappedValue)
        }

        try await wfr1.find(FR1.self).proceedInWorkflow()
        try await wfr1.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssertTrue(try wfr1.find(ViewType.Sheet.self).isPresented())

        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertThrowsError(try wfr2.find(FR2.self))
        XCTAssertNoThrow(try wfr2.find(FR4.self))

        let wfr3 = try await wfr2.extractWrappedWorkflowItem()
        XCTAssertThrowsError(try wfr3.find(FR3.self))
        XCTAssertNoThrow(try wfr3.find(FR4.self))

        let wfr4 = try await wfr3.extractWrappedWorkflowItem()
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
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self).presentationType(.modal)
                    }.presentationType(.modal)
                }
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowItem()

        let model = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_model") as? EnvironmentObject<WorkflowViewModel>)?.wrappedValue)
        }
        let launcher = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_launcher") as? EnvironmentObject<Launcher>)?.wrappedValue)
        }

        try await wfr1.find(FR1.self).proceedInWorkflow()
        try await wfr1.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssertTrue(try wfr1.find(ViewType.Sheet.self).isPresented())

        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        try await wfr2.find(FR2.self).proceedInWorkflow()
        XCTAssertThrowsError(try wfr2.find(FR3.self))

        let wfr3 = try await wfr2.extractWrappedWorkflowItem()
        XCTAssertThrowsError(try wfr3.find(FR3.self))

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }
}
