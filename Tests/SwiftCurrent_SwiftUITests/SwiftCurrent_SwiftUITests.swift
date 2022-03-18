//
//  SwiftCurrent_SwiftUIConsumerTests.swift
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
final class SwiftCurrent_SwiftUIConsumerTests: XCTestCase, App {
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
        let launcher = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self)
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
        }.hostAndInspect(with: \.inspection)

        XCTAssertEqual(try launcher.find(FR1.self).text().string(), "FR1 type")
        try await launcher.find(FR1.self).proceedInWorkflow()
        let fr2 = try launcher.find(FR2.self)
        XCTAssertEqual(try fr2.text().string(), "FR2 type")
        XCTAssertNoThrow(try fr2.actualView().proceedInWorkflow())

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    func testWorkflowCanBuildOptionalItem_WhenTrue() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }
        let expectOnFinish = expectation(description: "OnFinish called")
        let launcher = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                if true {
                    WorkflowItem(FR2.self)
                }
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
        }.hostAndInspect(with: \.inspection)

        XCTAssertEqual(try launcher.find(FR1.self).text().string(), "FR1 type")
        try await launcher.find(FR1.self).proceedInWorkflow()
        let fr2 = try launcher.find(FR2.self)
        XCTAssertEqual(try fr2.text().string(), "FR2 type")
        XCTAssertNoThrow(try fr2.actualView().proceedInWorkflow())

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    func testWorkflowCanBuildOptionalItem_WhenFalse() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }
        let expectOnFinish = expectation(description: "OnFinish called")
        let launcher = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                if false {
                    WorkflowItem(FR2.self)
                }
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
        }.hostAndInspect(with: \.inspection)

        XCTAssertEqual(try launcher.find(FR1.self).text().string(), "FR1 type")
        try await launcher.find(FR1.self).proceedInWorkflow()

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    func testWorkflowCanBuildEitherItem_WhenTrue() async throws {
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
        let launcher = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                if true {
                    WorkflowItem(FR2.self)
                } else {
                    WorkflowItem(FR3.self)
                }
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
        }.hostAndInspect(with: \.inspection)

        XCTAssertEqual(try launcher.find(FR1.self).text().string(), "FR1 type")
        try await launcher.find(FR1.self).proceedInWorkflow()
        let fr2 = try launcher.find(FR2.self)
        XCTAssertEqual(try fr2.text().string(), "FR2 type")
        XCTAssertNoThrow(try fr2.actualView().proceedInWorkflow())

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    func testWorkflowCanBuildEitherItem_WhenFalse() async throws {
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
        let launcher = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                if false {
                    WorkflowItem(FR2.self)
                } else {
                    WorkflowItem(FR3.self)
                }
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
        }.hostAndInspect(with: \.inspection)

        XCTAssertEqual(try launcher.find(FR1.self).text().string(), "FR1 type")
        try await launcher.find(FR1.self).proceedInWorkflow()
        let fr2 = try launcher.find(FR3.self)
        XCTAssertEqual(try fr2.text().string(), "FR3 type")
        XCTAssertNoThrow(try fr2.actualView().proceedInWorkflow())

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    func testWorkflowCanHaveMultipleOnFinishClosures() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }
        let expectOnFinish1 = expectation(description: "OnFinish1 called")
        let expectOnFinish2 = expectation(description: "OnFinish2 called")
        let launcher = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
            }
            .onFinish { _ in
                expectOnFinish1.fulfill()
            }.onFinish { _ in
                expectOnFinish2.fulfill()
            }
        }.hostAndInspect(with: \.inspection)

        try await launcher.find(FR1.self).proceedInWorkflow()

        wait(for: [expectOnFinish1, expectOnFinish2], timeout: TestConstant.timeout)
    }

    func testWorkflowCanFinishMultipleTimes() async throws {
        throw XCTSkip("We are currently unable to test this because of a limitation in ViewInspector, see here: https://github.com/nalexn/ViewInspector/issues/126")
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }
        @MainActor struct TestUtils {
            static var showWorkflow = Binding(wrappedValue: true)
        }
        let expectOnFinish1 = expectation(description: "OnFinish1 called")
        let expectOnFinish2 = expectation(description: "OnFinish2 called")
        let launcher = try await MainActor.run {
            WorkflowView(isLaunched: TestUtils.showWorkflow) {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self)
            }
            .onFinish { _ in
                TestUtils.showWorkflow.wrappedValue = false
                TestUtils.showWorkflow.update()
            }
        }.hostAndInspect(with: \.inspection)

        try await launcher.find(FR1.self).proceedInWorkflow()
        try await launcher.find(FR2.self).proceedInWorkflow()
        await MainActor.run {
            TestUtils.showWorkflow.wrappedValue = true
            TestUtils.showWorkflow.update()
        }
        try await launcher.find(FR1.self).proceedInWorkflow()
        try await launcher.find(FR2.self).proceedInWorkflow()
        await MainActor.run {
            TestUtils.showWorkflow.wrappedValue = true
            TestUtils.showWorkflow.update()
        }
        try await launcher.find(FR1.self).proceedInWorkflow()
        try await launcher.find(FR2.self).proceedInWorkflow()

        wait(for: [expectOnFinish1, expectOnFinish2], timeout: TestConstant.timeout)
    }

    func testWorkflowPassesArgumentsToTheFirstItem() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            let stringProperty: String
            init(with: String) {
                self.stringProperty = with
            }
            var body: some View { Text("FR1 type") }
        }
        let expected = UUID().uuidString
        let launcher = try await MainActor.run {
            WorkflowView(isLaunched: .constant(true), launchingWith: expected) {
                WorkflowItem(FR1.self)
            }
        }.hostAndInspect(with: \.inspection)

        XCTAssertEqual(try launcher.find(FR1.self).actualView().stringProperty, expected)
    }

    func testWorkflowPassesArgumentsToTheFirstItem_WhenThatFirstItemTakesInAnyWorkflowPassedArgs() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            let property: AnyWorkflow.PassedArgs
            init(with: AnyWorkflow.PassedArgs) {
                self.property = with
            }
            var body: some View { Text("FR1 type") }
        }
        let expected = UUID().uuidString
        let launcher = try await MainActor.run {
            WorkflowView(isLaunched: .constant(true), launchingWith: expected) {
                WorkflowItem(FR1.self)
                WorkflowItem(FR1.self)
            }
        }.hostAndInspect(with: \.inspection)

        XCTAssertEqual(try launcher.find(FR1.self).actualView().property.extractArgs(defaultValue: nil) as? String, expected)
    }

    func testWorkflowPassesArgumentsToTheFirstItem_WhenThatFirstItemTakesInAnyWorkflowPassedArgs_AndTheLaunchArgsAreAnyWorkflowPassedArgs() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            typealias WorkflowOutput = AnyWorkflow.PassedArgs
            var _workflowPointer: AnyFlowRepresentable?
            let property: AnyWorkflow.PassedArgs
            init(with: AnyWorkflow.PassedArgs) {
                self.property = with
            }
            var body: some View { Text("FR1 type") }
        }
        let expected = UUID().uuidString
        let launcher = try await MainActor.run {
            WorkflowView(isLaunched: .constant(true), launchingWith: AnyWorkflow.PassedArgs.args(expected)) {
                WorkflowItem(FR1.self)
                WorkflowItem(FR1.self)
            }
        }.hostAndInspect(with: \.inspection)

        XCTAssertEqual(try launcher.find(FR1.self).actualView().property.extractArgs(defaultValue: nil) as? String, expected)
    }

    func testWorkflowPassesArgumentsToAllItems() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            let property: String
            init(with: String) {
                self.property = with
            }
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            typealias WorkflowOutput = Bool
            var _workflowPointer: AnyFlowRepresentable?
            let property: Int
            init(with: Int) {
                self.property = with
            }
            var body: some View { Text("FR1 type") }
        }
        struct FR3: View, FlowRepresentable, Inspectable {
            typealias WorkflowOutput = String
            var _workflowPointer: AnyFlowRepresentable?
            let property: Bool
            init(with: Bool) {
                self.property = with
            }
            var body: some View { Text("FR1 type") }
        }
        let expectedFR1 = UUID().uuidString
        let expectedFR2 = Int.random(in: 1...10)
        let expectedFR3 = Bool.random()
        let expectedEnd = UUID().uuidString

        let launcher = try await MainActor.run {
            WorkflowView(isLaunched: .constant(true), launchingWith: expectedFR1) {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self)
                WorkflowItem(FR3.self)
            }
            .onFinish {
                XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedEnd)
            }
        }.hostAndInspect(with: \.inspection)

        XCTAssertEqual(try launcher.find(FR1.self).actualView().property, expectedFR1)
        try await launcher.find(FR1.self).proceedInWorkflow(expectedFR2)
        XCTAssertEqual(try launcher.find(FR2.self).actualView().property, expectedFR2)
        try await launcher.find(FR2.self).proceedInWorkflow(expectedFR3)
        XCTAssertEqual(try launcher.find(FR3.self).actualView().property, expectedFR3)
        try await launcher.find(FR3.self).proceedInWorkflow(expectedEnd)
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

        let launcher = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self)
                WorkflowItem(FR3.self)
                WorkflowItem(FR4.self)
                WorkflowItem(FR5.self)
                WorkflowItem(FR6.self)
                WorkflowItem(FR7.self)
            }
        }.hostAndInspect(with: \.inspection)

        try await launcher.find(FR1.self).proceedInWorkflow()
        try await launcher.find(FR2.self).proceedInWorkflow()
        try await launcher.find(FR3.self).proceedInWorkflow()
        try await launcher.find(FR4.self).proceedInWorkflow()
        try await launcher.find(FR5.self).proceedInWorkflow()
        try await launcher.find(FR6.self).proceedInWorkflow()
        try await launcher.find(FR7.self).proceedInWorkflow()
    }

    func testWorkflowOnlyShowsOneViewAtATime() async throws {
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
        let launcher = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self)
                WorkflowItem(FR3.self)
                WorkflowItem(FR2.self)
            }
        }.hostAndInspect(with: \.inspection)

        try await launcher.find(FR1.self).proceedInWorkflow()
        try await launcher.find(FR2.self).proceedInWorkflow()
        try await launcher.find(FR3.self).proceedInWorkflow()
        try await launcher.find(FR2.self).proceedInWorkflow()
        XCTAssertThrowsError(try launcher.find(ViewType.Text.self, skipFound: 1))
    }

    func testMovingBiDirectionallyInAWorkflow() async throws {
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
        let launcher = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self)
                WorkflowItem(FR3.self)
                WorkflowItem(FR4.self)
            }
        }.hostAndInspect(with: \.inspection)

        try await launcher.find(FR1.self).proceedInWorkflow()
        XCTAssertNoThrow(try launcher.find(FR2.self).actualView().backUpInWorkflow())
        try await launcher.find(FR1.self).proceedInWorkflow()
        try await launcher.find(FR2.self).proceedInWorkflow()
        XCTAssertNoThrow(try launcher.find(FR3.self).actualView().backUpInWorkflow())
        try await launcher.find(FR2.self).proceedInWorkflow()
        try await launcher.find(FR3.self).proceedInWorkflow()
        try await launcher.find(FR4.self).proceedInWorkflow()
    }

    func testWorkflowSetsBindingBooleanToFalseWhenAbandoned() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        let isLaunched = Binding(wrappedValue: true)
        let expectOnAbandon = expectation(description: "OnAbandon called")
        let launcher = try await MainActor.run {
            WorkflowView(isLaunched: isLaunched) {
                WorkflowItem(FR1.self)
            }
            .onAbandon {
                XCTAssertFalse(isLaunched.wrappedValue)
                expectOnAbandon.fulfill()
            }
        }.hostAndInspect(with: \.inspection)

        XCTAssertEqual(try launcher.find(FR1.self).text().string(), "FR1 type")
        try await launcher.find(FR1.self).abandonWorkflow()
        XCTAssertThrowsError(try launcher.find(FR1.self))

        wait(for: [expectOnAbandon], timeout: TestConstant.timeout)
    }

    func testWorkflowCanHaveMultipleOnAbandonCallbacks() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        let isLaunched = Binding(wrappedValue: true)
        let expectOnAbandon1 = expectation(description: "OnAbandon1 called")
        let expectOnAbandon2 = expectation(description: "OnAbandon2 called")

        let launcher = try await MainActor.run {
            WorkflowView(isLaunched: isLaunched) {
                WorkflowItem(FR1.self)
            }
            .onAbandon {
                XCTAssertFalse(isLaunched.wrappedValue)
                expectOnAbandon1.fulfill()
            }.onAbandon {
                XCTAssertFalse(isLaunched.wrappedValue)
                expectOnAbandon2.fulfill()
            }
        }.hostAndInspect(with: \.inspection)

        try await launcher.find(FR1.self).abandonWorkflow()
        XCTAssertThrowsError(try launcher.find(FR1.self))

        wait(for: [expectOnAbandon1, expectOnAbandon2], timeout: TestConstant.timeout)
    }

    func testWorkflowCanHaveModifiers() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }

            func customModifier() -> Self { self }
        }

        let launcher = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self).applyModifiers { $0.customModifier().padding().onAppear { } }
            }
        }.hostAndInspect(with: \.inspection)

        XCTAssert(try launcher.find(FR1.self).hasPadding())
        XCTAssertNoThrow(try launcher.find(FR1.self).callOnAppear())
    }

    func testWorkflowRelaunchesWhenSubsequentlyLaunched() async throws {
        throw XCTSkip("We are currently unable to test this because of a limitation in ViewInspector, see here: https://github.com/nalexn/ViewInspector/issues/126")
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }

            func customModifier() -> Self { self }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }

        @MainActor struct TestUtils {
            static let binding = Binding(wrappedValue: true)
        }

        let launcher = try await MainActor.run {
            WorkflowView(isLaunched: TestUtils.binding) {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self)
            }
        }.hostAndInspect(with: \.inspection)

        try await launcher.find(FR1.self).proceedInWorkflow()

        await MainActor.run { TestUtils.binding.wrappedValue = false }
        XCTAssertThrowsError(try launcher.find(FR1.self))
        XCTAssertThrowsError(try launcher.find(FR2.self))

        await MainActor.run { TestUtils.binding.wrappedValue = true }
        XCTAssertNoThrow(try launcher.callOnChange(newValue: false))
        XCTAssertNoThrow(try launcher.find(FR1.self))
        XCTAssertThrowsError(try launcher.find(FR2.self))

    }

    func testWorkflowRelaunchesWhenAbandoned_WithAConstantOfTrue() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }

            func abandon() {
                workflow?.abandon()
            }
        }
        let onFinishCalled = expectation(description: "onFinish Called")

        let launcher = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self)
            }
            .onFinish { _ in
                onFinishCalled.fulfill()
            }
        }.hostAndInspect(with: \.inspection)

        try await launcher.find(FR1.self).proceedInWorkflow()
        XCTAssertNoThrow(try launcher.find(FR2.self).actualView().abandon())
        XCTAssertThrowsError(try launcher.find(FR2.self))
        try await launcher.find(FR1.self).proceedInWorkflow()
        try await launcher.find(FR2.self).proceedInWorkflow()

        wait(for: [onFinishCalled], timeout: TestConstant.timeout)
    }

    func testWorkflowCanHaveAPassthroughRepresentable() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            typealias WorkflowOutput = AnyWorkflow.PassedArgs
            var _workflowPointer: AnyFlowRepresentable?
            private let data: AnyWorkflow.PassedArgs
            var body: some View { Text("FR1 type") }

            init(with data: AnyWorkflow.PassedArgs) {
                self.data = data
            }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            init(with str: String) { }
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }
        let expectOnFinish = expectation(description: "OnFinish called")
        let expectedArgs = UUID().uuidString
        let launcher = try await MainActor.run {
            WorkflowView(isLaunched: .constant(true), launchingWith: expectedArgs) {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self)
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
        }.hostAndInspect(with: \.inspection)

        XCTAssertEqual(try launcher.find(FR1.self).text().string(), "FR1 type")
        try await launcher.find(FR1.self).proceedInWorkflow(.args(expectedArgs))
        XCTAssertEqual(try launcher.find(FR2.self).text().string(), "FR2 type")
        try await launcher.find(FR2.self).proceedInWorkflow()

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    func testWorkflowCanConvertAnyArgsToCorrectTypeForFirstItem() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            let data: String

            var body: some View { Text("FR1 type") }

            init(with data: String) {
                self.data = data
            }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            init(with str: String) { }
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }
        let expectOnFinish = expectation(description: "OnFinish called")
        let expectedArgs = UUID().uuidString
        let launcher = try await MainActor.run {
            WorkflowView(isLaunched: .constant(true), launchingWith: AnyWorkflow.PassedArgs.args(expectedArgs)) {
                WorkflowItem(FR1.self)
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
        }.hostAndInspect(with: \.inspection)

        XCTAssertEqual(try launcher.find(FR1.self).text().string(), "FR1 type")
        XCTAssertEqual(try launcher.find(FR1.self).actualView().data, expectedArgs)
        try await launcher.find(FR1.self).proceedInWorkflow()

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    func testWorkflowCanHaveAPassthroughRepresentableInTheMiddle() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            typealias WorkflowOutput = AnyWorkflow.PassedArgs
            var _workflowPointer: AnyFlowRepresentable?
            private let data: AnyWorkflow.PassedArgs
            var body: some View { Text("FR2 type") }

            init(with data: AnyWorkflow.PassedArgs) {
                self.data = data
            }
        }
        struct FR3: View, FlowRepresentable, Inspectable {
            let str: String
            init(with str: String) {
                self.str = str
            }
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR3 type, \(str)") }
        }
        let expectOnFinish = expectation(description: "OnFinish called")
        let expectedArgs = UUID().uuidString
        let launcher = try await MainActor.run {
            WorkflowView {
                WorkflowItem(FR1.self)
                WorkflowItem(FR2.self)
                WorkflowItem(FR3.self)
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
        }.hostAndInspect(with: \.inspection)

        XCTAssertEqual(try launcher.find(FR1.self).text().string(), "FR1 type")
        try await launcher.find(FR1.self).proceedInWorkflow()
        XCTAssertEqual(try launcher.find(FR2.self).text().string(), "FR2 type")
        try await launcher.find(FR2.self).proceedInWorkflow(.args(expectedArgs))
        XCTAssertEqual(try launcher.find(FR3.self).text().string(), "FR3 type, \(expectedArgs)")
        try await launcher.find(FR3.self).proceedInWorkflow()

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    func testWorkflowCorrectlyHandlesState() throws {
        struct FR1: View, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?

            var body: some View {
                Button("Proceed") { proceedInWorkflow() }
            }
        }

        let workflowView = WorkflowView {
            WorkflowItem(FR1.self)
        }

        typealias WorkflowViewContent = State<WorkflowLauncher<WorkflowItemWrapper<WorkflowItem<FR1, FR1>, Never>>>
        let content = try XCTUnwrap(Mirror(reflecting: workflowView).descendant("_content") as? WorkflowViewContent)
        // Note: Only add to these exceptions if you are *certain* the property should not be @State. Err on the side of the property being @State
        let exceptions = ["_model", "_launcher", "_location", "_value", "inspection", "_presentation", "_isLaunched"]

        let mirror = Mirror(reflecting: content.wrappedValue)

        XCTAssertGreaterThan(mirror.children.count, 0)

        mirror.children.forEach {
            guard let label = $0.label, !exceptions.contains(label) else { return }
            XCTAssert($0.value is StateIdentifiable, "Property named: \(label) was note @State")
        }
    }

    func testWorkflowCanHaveADelayedLaunch() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            weak var _workflowPointer: AnyFlowRepresentable?

            var body: some View {
                Button("Proceed") { proceedInWorkflow() }
            }
        }

        struct Wrapper: View, Inspectable {
            @State var showingWorkflow = false
            let inspection = Inspection<Self>()
            var body: some View {
                VStack {
                    Button("") { showingWorkflow = true }
                    WorkflowView(isLaunched: $showingWorkflow) {
                        WorkflowItem(FR1.self)
                    }
                }
                .onReceive(inspection.notice) { inspection.visit(self, $0) }
            }
        }

        let wrapper = try await MainActor.run { Wrapper() }.hostAndInspect(with: \.inspection)

        let stack = try wrapper.vStack()
        let launcher = try stack.view(WorkflowView<WorkflowLauncher<WorkflowItemWrapper<WorkflowItem<FR1, FR1>, Never>>>.self, 1).view(WorkflowLauncher<WorkflowItemWrapper<WorkflowItem<FR1, FR1>, Never>>.self)
        XCTAssertThrowsError(try launcher.view(WorkflowItemWrapper<WorkflowItem<FR1, FR1>, Never>.self))
        XCTAssertNoThrow(try stack.button(0).tap())
        XCTAssertNoThrow(try launcher.view(WorkflowItemWrapper<WorkflowItem<FR1, FR1>, Never>.self))
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
protocol StateIdentifiable { }

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension State: StateIdentifiable {

}
