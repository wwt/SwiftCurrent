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

#warning("tests rely on embedInNavigationView which ideally, is not a thing")

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
                WorkflowItem { FR1() }.presentationType(.navigationLink)
                WorkflowItem { FR2() }
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
            //.embedInNavigationView()
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        XCTAssertEqual(try wfr1.find(FR1.self).text().string(), "FR1 type")

        try await wfr1.proceedAndCheckNavLink(on: FR1.self)

        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertEqual(try wfr2.find(FR2.self).text().string(), "FR2 type")
        try await wfr2.find(FR2.self).proceedInWorkflow()

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    func testWorkflowCanBeFollowed_WithWorkflowGroup() async throws {
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
                WorkflowItem { FR1() }.presentationType(.navigationLink)
                WorkflowGroup {
                    WorkflowItem { FR2() }
                }
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
            //.embedInNavigationView()
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        XCTAssertEqual(try wfr1.find(FR1.self).text().string(), "FR1 type")

        try await wfr1.proceedAndCheckNavLink(on: FR1.self)

        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertEqual(try wfr2.find(FR2.self).text().string(), "FR2 type")
        try await wfr2.find(FR2.self).proceedInWorkflow()

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    func testWorkflowCanBeFollowed_WithBuildOptions_WhenTrue() async throws {
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
                WorkflowItem { FR1() }.presentationType(.navigationLink)
                if true {
                    WorkflowItem { FR2() }
                }
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
            //.embedInNavigationView()
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        XCTAssertEqual(try wfr1.find(FR1.self).text().string(), "FR1 type")

        try await wfr1.proceedAndCheckNavLink(on: FR1.self)

        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertEqual(try wfr2.find(FR2.self).text().string(), "FR2 type")
        try await wfr2.find(FR2.self).proceedInWorkflow()

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    func testWorkflowCanBeFollowed_WithBuildOptions_WhenFalse() async throws {
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
        let expectOnFinish = expectation(description: "OnFinish called")
        let wfr1 = try await MainActor.run {
            WorkflowView {
                WorkflowItem { FR1() }.presentationType(.navigationLink)
                if false {
                    WorkflowItem { FR2() }
                }
                WorkflowItem { FR3() }
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
            //.embedInNavigationView()
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        XCTAssertEqual(try wfr1.find(FR1.self).text().string(), "FR1 type")

        try await wfr1.proceedAndCheckNavLink(on: FR1.self)

        let wfr3 = try await wfr1.extractWrappedWrapper().extractWrappedWrapper()
        XCTAssertEqual(try wfr3.find(FR3.self).text().string(), "FR3 type")
        try await wfr3.find(FR3.self).proceedInWorkflow()

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    func testWorkflowCanBeFollowed_WithBuildEither_WhenTrue() async throws {
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
        let expectOnFinish = expectation(description: "OnFinish called")
        let wfr1 = try await MainActor.run {
            WorkflowView {
                WorkflowItem { FR1() }.presentationType(.navigationLink)
                if true {
                    WorkflowItem { FR2() }
                } else {
                    WorkflowItem { FR3() }
                }
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
            //.embedInNavigationView()
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        XCTAssertEqual(try wfr1.find(FR1.self).text().string(), "FR1 type")

        try await wfr1.proceedAndCheckNavLink(on: FR1.self)

        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertEqual(try wfr2.find(FR2.self).text().string(), "FR2 type")
        try await wfr2.find(FR2.self).proceedInWorkflow()

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    func testWorkflowCanBeFollowed_WithBuildEither_WhenFalse() async throws {
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
        let expectOnFinish = expectation(description: "OnFinish called")
        let wfr1 = try await MainActor.run {
            WorkflowView {
                WorkflowItem { FR1() }.presentationType(.navigationLink)
                if false {
                    WorkflowItem { FR2() }
                } else {
                    WorkflowItem { FR3() }
                }
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
            //.embedInNavigationView()
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        XCTAssertEqual(try wfr1.find(FR1.self).text().string(), "FR1 type")

        try await wfr1.proceedAndCheckNavLink(on: FR1.self)

        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertEqual(try wfr2.find(FR3.self).text().string(), "FR3 type")
        try await wfr2.find(FR3.self).proceedInWorkflow()

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    func testWorkflowItemsOfTheSameTypeCanBeFollowed() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }

        let wfr1 = try await MainActor.run {
            WorkflowView {
                WorkflowItem { FR1() }.presentationType(.navigationLink)
                WorkflowItem { FR1() }.presentationType(.navigationLink)
                WorkflowItem { FR1() }
            }//.embedInNavigationView()
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
                WorkflowItem { FR1() }.presentationType(.navigationLink)
                WorkflowItem { FR2() }.presentationType(.navigationLink)
                WorkflowItem { FR3() }.presentationType(.navigationLink)
                WorkflowItem { FR4() }.presentationType(.navigationLink)
                WorkflowItem { FR5() }.presentationType(.navigationLink)
                WorkflowItem { FR6() }.presentationType(.navigationLink)
                WorkflowItem { FR7() }.presentationType(.navigationLink)
            }//.embedInNavigationView()
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        try await wfr1.proceedAndCheckNavLink(on: FR1.self)

        let wfr2 = try await wfr1.extractWrappedWrapper()
        try await wfr2.proceedAndCheckNavLink(on: FR2.self)

        let wfr3 = try await wfr2.extractWrappedWrapper()
        try await wfr3.proceedAndCheckNavLink(on: FR3.self)

        let wfr4 = try await wfr3.extractWrappedWrapper()
        try await wfr4.proceedAndCheckNavLink(on: FR4.self)

        let wfr5 = try await wfr4.extractWrappedWrapper()
        try await wfr5.proceedAndCheckNavLink(on: FR5.self)

        let wfr6 = try await wfr5.extractWrappedWrapper()
        try await wfr6.proceedAndCheckNavLink(on: FR6.self)

        let wfr7 = try await wfr6.extractWrappedWrapper()
        try await wfr7.find(FR7.self).proceedInWorkflow()
    }

    func testWorkflowCanBeAbandoned() async throws {
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
            var body: some View {
                Button("continue") {
                    workflow?.abandon()
                }
            }
        }

        let wfr1 = try await MainActor.run {
            WorkflowView {
                WorkflowItem { FR1() }.presentationType(.navigationLink)
                WorkflowItem { FR2() }.presentationType(.navigationLink)
                WorkflowItem { FR3() }.presentationType(.navigationLink)
            }//.embedInNavigationView()
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        try await wfr1.proceedAndCheckNavLink(on: FR1.self)

        let wfr2 = try await wfr1.extractWrappedWrapper()
        try await wfr2.proceedAndCheckNavLink(on: FR2.self)

        let wfr3 = try await wfr2.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr3.find(button: "continue").tap())

        XCTAssertNoThrow(try wfr1.find(FR1.self))
        XCTAssertEqual(try wfr1.find(ViewType.NavigationLink.self).isActive(), false)
        XCTAssertThrowsError(try wfr2.find(FR2.self))
        XCTAssertThrowsError(try wfr3.find(FR3.self))
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
                WorkflowItem { FR1() }.presentationType(.navigationLink)
                WorkflowItem { FR2() }.presentationType(.navigationLink)
                WorkflowItem { FR3() }
            }
            //.embedInNavigationView()
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        XCTAssertThrowsError(try wfr1.find(FR1.self).actualView())

        let wfr2 = try await wfr1.extractWrappedWrapper()
        try await wfr2.proceedAndCheckNavLink(on: FR2.self)

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
                WorkflowItem { FR1() }.presentationType(.navigationLink)
                WorkflowItem { FR2() }.presentationType(.navigationLink)
                WorkflowItem { FR3() }
            }
            //.embedInNavigationView()
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        try await wfr1.proceedAndCheckNavLink(on: FR1.self)

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
                WorkflowItem { FR1() }.presentationType(.navigationLink)
                WorkflowItem { FR2() }.presentationType(.navigationLink)
                WorkflowItem { FR3() }
                WorkflowItem { FR4() }
            }
            //.embedInNavigationView()
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        try await wfr1.proceedAndCheckNavLink(on: FR1.self)

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
                WorkflowItem { FR1() }.presentationType(.navigationLink)
                WorkflowItem { FR2() }.presentationType(.navigationLink)
                WorkflowItem { FR3() }
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
            //.embedInNavigationView()
        }
        .hostAndInspect(with: \.inspection)
        .extractWorkflowLauncher()
        .extractWorkflowItemWrapper()

        try await wfr1.proceedAndCheckNavLink(on: FR1.self)

        let wfr2 = try await wfr1.extractWrappedWrapper()
        try await wfr2.proceedAndCheckNavLink(on: FR2.self)

        let wfr3 = try await wfr2.extractWrappedWrapper()
        XCTAssertThrowsError(try wfr3.find(FR3.self))
        XCTAssertNoThrow(try wfr2.find(FR2.self))

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    func testConvenienceEmbedInNavViewFunction() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }

        let launcherView = try await MainActor.run {
            WorkflowView {
                WorkflowItem { FR1() }.presentationType(.navigationLink)
            }//.embedInNavigationView()
        }.hostAndInspect(with: \.inspection)
            .extractWorkflowLauncher()

        let navView = try launcherView.navigationView()
        XCTAssert(try navView.navigationViewStyle() is StackNavigationViewStyle)
        XCTAssertNoThrow(try navView.view(WorkflowItemWrapper<WorkflowItem<FR1, FR1>, Never>.self, 0))
    }
}

@available(iOS 15.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension InspectableView where View: CustomViewType & SingleViewContent {
    fileprivate func proceedAndCheckNavLink<FR: FlowRepresentable & Inspectable>(on: FR.Type) async throws where FR.WorkflowOutput == Never {
        XCTAssertFalse(try find(ViewType.NavigationLink.self).isActive())

        try await find(FR.self).proceedInWorkflow()
    }
}
