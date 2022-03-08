//
//  SwiftCurrent_NavigationLinkTests.swift
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
final class SwiftCurrent_NavigationLinkTests: XCTestCase, View {
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
                WorkflowItem(FR1.self).presentationType(.navigationLink)
                WorkflowItem(FR2.self)
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        let model = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_model") as? EnvironmentObject<WorkflowViewModel>)?.wrappedValue)
        }
        let launcher = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_launcher") as? EnvironmentObject<Launcher>)?.wrappedValue)
        }

        XCTAssertEqual(try wfr1.find(FR1.self).text().string(), "FR1 type")
        XCTAssertFalse(try wfr1.find(ViewType.NavigationLink.self).isActive())
        try await wfr1.find(FR1.self).proceedInWorkflow()

        // needed to re-host to avoid some kind of race with the nav link
        try await wfr1.actualView().host { $0.environmentObject(model).environmentObject(launcher) }

        XCTAssertTrue(try wfr1.find(ViewType.NavigationLink.self).isActive())
        XCTAssertEqual(try wfr1.find(FR2.self).text().string(), "FR2 type")
        try await wfr1.find(FR2.self).proceedInWorkflow()

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    func testWorkflowItemsOfTheSameTypeCanBeFollowed() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }

        let wfr1 = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self).presentationType(.navigationLink)
                WorkflowItem(FR1.self).presentationType(.navigationLink)
                WorkflowItem(FR1.self)
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        let model = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_model") as? EnvironmentObject<WorkflowViewModel>)?.wrappedValue)
        }
        let launcher = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_launcher") as? EnvironmentObject<Launcher>)?.wrappedValue)
        }

        XCTAssertFalse(try wfr1.find(ViewType.NavigationLink.self).isActive())
        try await wfr1.find(FR1.self).proceedInWorkflow()
        // needed to re-host to avoid some kind of race with the nav link
        try await wfr1.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssert(try wfr1.find(ViewType.NavigationLink.self).isActive())

        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertFalse(try wfr2.find(ViewType.NavigationLink.self).isActive())
        try await wfr2.find(FR1.self).proceedInWorkflow()
        try await wfr2.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssert(try wfr2.find(ViewType.NavigationLink.self).isActive())

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
                WorkflowItem(FR1.self).presentationType(.navigationLink)
                WorkflowItem(FR2.self).presentationType(.navigationLink)
                WorkflowItem(FR3.self).presentationType(.navigationLink)
                WorkflowItem(FR4.self).presentationType(.navigationLink)
                WorkflowItem(FR5.self).presentationType(.navigationLink)
                WorkflowItem(FR6.self).presentationType(.navigationLink)
                WorkflowItem(FR7.self).presentationType(.navigationLink)
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        let model = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_model") as? EnvironmentObject<WorkflowViewModel>)?.wrappedValue)
        }
        let launcher = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_launcher") as? EnvironmentObject<Launcher>)?.wrappedValue)
        }

        XCTAssertFalse(try wfr1.find(ViewType.NavigationLink.self).isActive())
        try await wfr1.find(FR1.self).proceedInWorkflow()
        // needed to re-host to avoid some kind of race with the nav link
        try await wfr1.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssert(try wfr1.find(ViewType.NavigationLink.self).isActive())

        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertFalse(try wfr2.find(ViewType.NavigationLink.self).isActive())
        try await wfr2.find(FR2.self).proceedInWorkflow()
        try await wfr2.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssert(try wfr2.find(ViewType.NavigationLink.self).isActive())

        let wfr3 = try await wfr2.extractWrappedWrapper()
        XCTAssertFalse(try wfr3.find(ViewType.NavigationLink.self).isActive())
        try await wfr3.find(FR3.self).proceedInWorkflow()
        try await wfr3.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssert(try wfr3.find(ViewType.NavigationLink.self).isActive())

        let wfr4 = try await wfr3.extractWrappedWrapper()
        XCTAssertFalse(try wfr4.find(ViewType.NavigationLink.self).isActive())
        try await wfr4.find(FR4.self).proceedInWorkflow()
        try await wfr4.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssert(try wfr4.find(ViewType.NavigationLink.self).isActive())

        let wfr5 = try await wfr4.extractWrappedWrapper()
        XCTAssertFalse(try wfr5.find(ViewType.NavigationLink.self).isActive())
        try await wfr5.find(FR5.self).proceedInWorkflow()
        try await wfr5.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssert(try wfr5.find(ViewType.NavigationLink.self).isActive())

        let wfr6 = try await wfr5.extractWrappedWrapper()
        XCTAssertFalse(try wfr6.find(ViewType.NavigationLink.self).isActive())
        try await wfr6.find(FR6.self).proceedInWorkflow()
        try await wfr6.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssert(try wfr6.find(ViewType.NavigationLink.self).isActive())

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
                WorkflowItem(FR1.self).presentationType(.navigationLink)
                WorkflowItem(FR2.self).presentationType(.navigationLink)
                WorkflowItem(FR3.self)
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        let model = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_model") as? EnvironmentObject<WorkflowViewModel>)?.wrappedValue)
        }
        let launcher = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_launcher") as? EnvironmentObject<Launcher>)?.wrappedValue)
        }

        XCTAssertThrowsError(try wfr1.find(FR1.self).actualView())

        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertFalse(try wfr2.find(ViewType.NavigationLink.self).isActive())
        try await wfr2.find(FR2.self).proceedInWorkflow()
        try await wfr2.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssert(try wfr2.find(ViewType.NavigationLink.self).isActive())

        let wfr3 = try await wfr2.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr3.find(FR3.self).actualView())
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
                WorkflowItem(FR1.self).presentationType(.navigationLink)
                WorkflowItem(FR2.self).presentationType(.navigationLink)
                WorkflowItem(FR3.self)
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        let model = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_model") as? EnvironmentObject<WorkflowViewModel>)?.wrappedValue)
        }
        let launcher = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_launcher") as? EnvironmentObject<Launcher>)?.wrappedValue)
        }
        XCTAssertFalse(try wfr1.find(ViewType.NavigationLink.self).isActive())
        try await wfr1.find(FR1.self).proceedInWorkflow()
        // needed to re-host to avoid some kind of race with the nav link
        try await wfr1.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssert(try wfr1.find(ViewType.NavigationLink.self).isActive())

        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertThrowsError(try wfr2.find(FR2.self))

        let wfr3 = try await wfr2.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr3.find(FR3.self).actualView())
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
                WorkflowItem(FR1.self).presentationType(.navigationLink)
                WorkflowItem(FR2.self).presentationType(.navigationLink)
                WorkflowItem(FR3.self)
                WorkflowItem(FR4.self)
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        let model = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_model") as? EnvironmentObject<WorkflowViewModel>)?.wrappedValue)
        }
        let launcher = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_launcher") as? EnvironmentObject<Launcher>)?.wrappedValue)
        }
        XCTAssertFalse(try wfr1.find(ViewType.NavigationLink.self).isActive())
        try await wfr1.find(FR1.self).proceedInWorkflow()
        // needed to re-host to avoid some kind of race with the nav link
        try await wfr1.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssert(try wfr1.find(ViewType.NavigationLink.self).isActive())

        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertThrowsError(try wfr2.find(FR2.self))

        let wfr3 = try await wfr2.extractWrappedWrapper()
        XCTAssertThrowsError(try wfr3.find(FR3.self).actualView())

        let wfr4 = try await wfr3.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr4.find(FR4.self).actualView())
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
                WorkflowItem(FR1.self).presentationType(.navigationLink)
                WorkflowItem(FR2.self).presentationType(.navigationLink)
                WorkflowItem(FR3.self)
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        let model = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_model") as? EnvironmentObject<WorkflowViewModel>)?.wrappedValue)
        }
        let launcher = try await MainActor.run {
            try XCTUnwrap((Mirror(reflecting: try wfr1.actualView()).descendant("_launcher") as? EnvironmentObject<Launcher>)?.wrappedValue)
        }

        XCTAssertFalse(try wfr1.find(ViewType.NavigationLink.self).isActive())
        try await wfr1.find(FR1.self).proceedInWorkflow()
        // needed to re-host to avoid some kind of race with the nav link
        try await wfr1.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssert(try wfr1.find(ViewType.NavigationLink.self).isActive())

        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertFalse(try wfr2.find(ViewType.NavigationLink.self).isActive())
        try await wfr2.find(FR2.self).proceedInWorkflow()
        try await wfr2.actualView().host { $0.environmentObject(model).environmentObject(launcher) }
        XCTAssertFalse(try wfr2.find(ViewType.NavigationLink.self).isActive())

        let wfr3 = try await wfr2.extractWrappedWrapper()
        XCTAssertThrowsError(try wfr3.find(FR3.self))
        XCTAssertNoThrow(try wfr2.find(FR2.self))

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    func testConvenienceEmbedInNavViewFunction() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }

        let launcherView = WorkflowView {
            WorkflowItem(FR1.self).presentationType(.navigationLink)
        }.embedInNavigationView()

        let expectViewLoaded = launcherView.inspection.inspect { launcher in
            let navView = try launcher.navigationView()
            XCTAssert(try navView.navigationViewStyle() is StackNavigationViewStyle)
            XCTAssertNoThrow(try navView.view(WorkflowItem<FR1, FR1>.self, 0))
        }
        ViewHosting.host(view: launcherView)
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }
}
