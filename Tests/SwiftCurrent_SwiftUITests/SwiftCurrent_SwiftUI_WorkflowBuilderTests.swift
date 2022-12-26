//
//  SwiftCurrent_SwiftUI_WorkflowBuilderTests.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 2/21/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import XCTest
import SwiftUI
import ViewInspector

import SwiftCurrent
@testable import SwiftCurrent_SwiftUI // testable sadly needed for inspection.inspect to work

@available(iOS 15.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class SwiftCurrent_SwiftUI_WorkflowBuilderTests: XCTestCase {
    func testWorkflowCanBeFollowed() async throws {
        struct FR1: View {
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View {
            var body: some View { Text("FR2 type") }
        }
        let expectOnFinish = expectation(description: "OnFinish called")
        let viewUnderTest = try await MainActor.run {
            WorkflowView {
                WorkflowItem { FR1() }
                WorkflowItem { FR2() }
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try viewUnderTest.find(FR1.self).text().string(), "FR1 type")
        try await viewUnderTest.find(FR1.self).proceedInWorkflow()
        XCTAssertEqual(try viewUnderTest.find(FR2.self).text().string(), "FR2 type")
        try await viewUnderTest.find(FR2.self).proceedInWorkflow()
        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    func testWorkflowCanHaveMultipleOnFinishClosures() async throws {
        struct FR1: View {
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View {
            var body: some View { Text("FR2 type") }
        }
        let expectOnFinish1 = expectation(description: "OnFinish1 called")
        let expectOnFinish2 = expectation(description: "OnFinish2 called")

        let viewUnderTest = try await MainActor.run {
            WorkflowView {
                WorkflowItem { FR1() }
            }
            .onFinish { _ in
                expectOnFinish1.fulfill()
            }.onFinish { _ in
                expectOnFinish2.fulfill()
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await viewUnderTest.find(FR1.self).proceedInWorkflow()
        wait(for: [expectOnFinish1, expectOnFinish2], timeout: TestConstant.timeout)
    }

    func testWorkflowPassesArgumentsToTheFirstItem() async throws {
        struct FR1: View {
            let stringProperty: String
            init(with string: String) {
                self.stringProperty = string
            }
            var body: some View { Text("FR1 type") }
        }
        let expected = UUID().uuidString

        let viewUnderTest = try await MainActor.run {
            WorkflowView(launchingWith: expected) {
                WorkflowItem { (args: String) in FR1(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try viewUnderTest.find(FR1.self).actualView().stringProperty, expected)
    }

    func testWorkflowPassesArgumentsToTheFirstItem_WhenThatFirstItemTakesInAnyWorkflowPassedArgs() async throws {
        struct FR1: View {
            let property: AnyWorkflow.PassedArgs
            init(with: AnyWorkflow.PassedArgs) {
                self.property = with
            }
            var body: some View { Text("FR1 type") }
        }
        let expected = UUID().uuidString

        let viewUnderTest = try await MainActor.run {
            WorkflowView(launchingWith: expected) {
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try viewUnderTest.find(FR1.self).actualView().property.extractArgs(defaultValue: nil) as? String, expected)
    }

    func testWorkflowPassesArgumentsToTheFirstItem_WhenThatFirstItemTakesInAnyWorkflowPassedArgs_AndTheLaunchArgsAreAnyWorkflowPassedArgs() async throws {
        struct FR1: View {
            typealias WorkflowOutput = AnyWorkflow.PassedArgs
            let property: AnyWorkflow.PassedArgs
            init(with: AnyWorkflow.PassedArgs) {
                self.property = with
            }
            var body: some View { Text("FR1 type") }
        }
        let expected = UUID().uuidString

        let viewUnderTest = try await MainActor.run {
            WorkflowView(launchingWith: AnyWorkflow.PassedArgs.args(expected)) {
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try viewUnderTest.find(FR1.self).actualView().property.extractArgs(defaultValue: nil) as? String, expected)
    }

    func testWorkflowPassesArgumentsToAllItems() async throws {
        struct FR1: View {
            typealias WorkflowOutput = Int
            let property: String
            init(with: String) {
                self.property = with
            }
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View {
            typealias WorkflowOutput = Bool
            let property: Int
            init(with: Int) {
                self.property = with
            }
            var body: some View { Text("FR1 type") }
        }
        struct FR3: View {
            typealias WorkflowOutput = String
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

        let viewUnderTest = try await MainActor.run {
            WorkflowView(launchingWith: expectedFR1) {
                WorkflowItem { (args: String) in FR1(with: args) }
                WorkflowItem { (args: Int) in FR2(with: args) }
                WorkflowItem { (args: Bool) in FR3(with: args) }
            }
            .onFinish {
                XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedEnd)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try viewUnderTest.find(FR1.self).actualView().property, expectedFR1)
        try await viewUnderTest.find(FR1.self).proceedInWorkflow(expectedFR2)
        XCTAssertEqual(try viewUnderTest.find(FR2.self).actualView().property, expectedFR2)
        try await viewUnderTest.find(FR2.self).proceedInWorkflow(expectedFR3)
        XCTAssertEqual(try viewUnderTest.find(FR3.self).actualView().property, expectedFR3)
        try await viewUnderTest.find(FR3.self).proceedInWorkflow(expectedEnd)
    }

    func testLargeWorkflowCanBeFollowed() async throws {
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
        struct FR5: View {
            var body: some View { Text("FR5 type") }
        }
        struct FR6: View {
            var body: some View { Text("FR6 type") }
        }
        struct FR7: View {
            var body: some View { Text("FR7 type") }
        }
        struct FR8: View {
            var body: some View { Text("FR7 type") }
        }
        struct FR9: View {
            var body: some View { Text("FR7 type") }
        }
        struct FR10: View {
            var body: some View { Text("FR7 type") }
        }

        let viewUnderTest = try await MainActor.run {
            WorkflowView {
                WorkflowItem { FR1() }
                WorkflowItem { FR2() }
                WorkflowItem { FR3() }
                WorkflowItem { FR4() }
                WorkflowItem { FR5() }
                WorkflowItem { FR6() }
                WorkflowItem { FR7() }
                WorkflowItem { FR8() }
                WorkflowItem { FR9() }
                WorkflowItem { FR10() }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await viewUnderTest.find(FR1.self).proceedInWorkflow()
        try await viewUnderTest.find(FR2.self).proceedInWorkflow()
        try await viewUnderTest.find(FR3.self).proceedInWorkflow()
        try await viewUnderTest.find(FR4.self).proceedInWorkflow()
        try await viewUnderTest.find(FR5.self).proceedInWorkflow()
        try await viewUnderTest.find(FR6.self).proceedInWorkflow()
        try await viewUnderTest.find(FR7.self).proceedInWorkflow()
        try await viewUnderTest.find(FR8.self).proceedInWorkflow()
        try await viewUnderTest.find(FR9.self).proceedInWorkflow()
        try await viewUnderTest.find(FR10.self).proceedInWorkflow()
    }

    func testWorkflowOnlyShowsOneViewAtATime() async throws {
        struct FR1: View {
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View {
            var body: some View { Text("FR2 type") }
        }
        struct FR3: View {
            var body: some View { Text("FR3 type") }
        }

        let viewUnderTest = try await MainActor.run {
            WorkflowView {
                WorkflowItem { FR1() }
                WorkflowItem { FR2() }
                WorkflowItem { FR3() }
                WorkflowItem { FR2() }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await viewUnderTest.find(FR1.self).proceedInWorkflow()
        XCTAssertThrowsError(try viewUnderTest.find(FR1.self))
        try await viewUnderTest.find(FR2.self).proceedInWorkflow()
        XCTAssertThrowsError(try viewUnderTest.find(FR2.self))
        try await viewUnderTest.find(FR3.self).proceedInWorkflow()
        XCTAssertThrowsError(try viewUnderTest.find(FR3.self))
        try await viewUnderTest.find(FR2.self).proceedInWorkflow()
        XCTAssertThrowsError(try viewUnderTest.find(ViewType.Text.self, skipFound: 1))
    }

    func testMovingBiDirectionallyInAWorkflow() async throws {
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

        let viewUnderTest = try await MainActor.run {
            WorkflowView {
                WorkflowItem { FR1() }
                WorkflowItem { FR2() }
                WorkflowItem { FR3() }
                WorkflowItem { FR4() }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await viewUnderTest.find(FR1.self).proceedInWorkflow()
        try await viewUnderTest.find(FR2.self).backUpInWorkflow()
        try await viewUnderTest.find(FR1.self).proceedInWorkflow()
        try await viewUnderTest.find(FR2.self).proceedInWorkflow()
        try await viewUnderTest.find(FR3.self).backUpInWorkflow()
        try await viewUnderTest.find(FR2.self).proceedInWorkflow()
        try await viewUnderTest.find(FR3.self).proceedInWorkflow()
        try await viewUnderTest.find(FR4.self).proceedInWorkflow()
    }

    func testWorkflowSetsBindingBooleanToFalseWhenAbandoned() async throws {
        struct FR1: View {
            var body: some View { Text("FR1 type") }
        }
        let isLaunched = Binding(wrappedValue: true)
        let expectOnAbandon = expectation(description: "OnAbandon called")

        let viewUnderTest = try await MainActor.run {
            WorkflowView(isLaunched: isLaunched) {
                WorkflowItem { FR1() }
            }.onAbandon {
                XCTAssertFalse(isLaunched.wrappedValue)
                expectOnAbandon.fulfill()
            }
        }.hostAndInspect(with: \.inspection)

        XCTAssertEqual(try viewUnderTest.find(FR1.self).text().string(), "FR1 type")
        try await viewUnderTest.find(FR1.self).abandonWorkflow()
        XCTAssertThrowsError(try viewUnderTest.find(FR1.self))

        wait(for: [expectOnAbandon], timeout: TestConstant.timeout)
    }

    func testWorkflowCanHaveMultipleOnAbandonCallbacks() async throws {
        struct FR1: View {
            var body: some View { Text("FR1 type") }
        }
        let isLaunched = Binding(wrappedValue: true)
        let expectOnAbandon1 = expectation(description: "OnAbandon1 called")
        let expectOnAbandon2 = expectation(description: "OnAbandon2 called")

        let viewUnderTest = try await MainActor.run {
            WorkflowView(isLaunched: isLaunched) {
                WorkflowItem { FR1() }
            }
            .onAbandon {
                XCTAssertFalse(isLaunched.wrappedValue)
                expectOnAbandon1.fulfill()
            }.onAbandon {
                XCTAssertFalse(isLaunched.wrappedValue)
                expectOnAbandon2.fulfill()
            }
        }.hostAndInspect(with: \.inspection)

        try await viewUnderTest.find(FR1.self).abandonWorkflow()
        XCTAssertThrowsError(try viewUnderTest.find(FR1.self))
        wait(for: [expectOnAbandon1, expectOnAbandon2], timeout: TestConstant.timeout)
    }

    func testWorkflowCanHaveModifiers() async throws {
        struct FR1: View {
            var body: some View { Text("FR1 type") }

            func customModifier() -> Self { self }
        }

        let viewUnderTest = try await MainActor.run {
            WorkflowView {
                WorkflowItem { FR1().customModifier().padding().onAppear { } }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssert(try viewUnderTest.find(FR1.self).hasPadding())
        XCTAssertNoThrow(try viewUnderTest.find(FR1.self).callOnAppear())
    }

    func testWorkflowRelaunchesWhenSubsequentlyLaunched() async throws {
        throw XCTSkip("We are currently unable to test this because of a limitation in ViewInspector, see here: https://github.com/nalexn/ViewInspector/issues/126")
        struct FR1: View {
            var body: some View { Text("FR1 type") }

            func customModifier() -> Self { self }
        }
        struct FR2: View {
            var body: some View { Text("FR2 type") }
        }

        let binding = Binding(wrappedValue: true)

        let viewUnderTest = try await MainActor.run {
            WorkflowView(isLaunched: binding) {
                WorkflowItem { FR1() }
                WorkflowItem { FR2() }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await viewUnderTest.find(FR1.self).proceedInWorkflow()

        binding.wrappedValue = false
        XCTAssertThrowsError(try viewUnderTest.find(FR1.self))
        XCTAssertThrowsError(try viewUnderTest.find(FR2.self))

        binding.wrappedValue = true
        XCTAssertNoThrow(try viewUnderTest.callOnChange(newValue: false))
        XCTAssertNoThrow(try viewUnderTest.find(FR1.self))
        XCTAssertThrowsError(try viewUnderTest.find(FR2.self))
    }

    func testWorkflowRelaunchesWhenAbandoned_WithAConstantOfTrue() async throws {
        struct FR1: View {
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View {
            var body: some View { Text("FR2 type") }

            func abandon() {
                #warning("Abandon is not a thing")
//                workflow?.abandon()
            }
        }
        let onFinishCalled = expectation(description: "onFinish Called")

        let viewUnderTest = try await MainActor.run {
            WorkflowView(isLaunched: .constant(true)) {
                WorkflowItem { FR1() }
                WorkflowItem { FR2() }
            }
            .onFinish { _ in
                onFinishCalled.fulfill()
            }
        }.hostAndInspect(with: \.inspection)

        try await viewUnderTest.find(FR1.self).proceedInWorkflow()
        XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().abandon())
        XCTAssertThrowsError(try viewUnderTest.find(FR2.self))
        try await viewUnderTest.find(FR1.self).proceedInWorkflow()
        try await viewUnderTest.find(FR2.self).proceedInWorkflow()

        wait(for: [onFinishCalled], timeout: TestConstant.timeout)
    }

    func testWorkflowCanHaveAPassthroughRepresentable() async throws {
        struct FR1: View {
            typealias WorkflowOutput = AnyWorkflow.PassedArgs
            private let data: AnyWorkflow.PassedArgs
            var body: some View { Text("FR1 type") }

            init(with data: AnyWorkflow.PassedArgs) {
                self.data = data
            }
        }
        struct FR2: View {
            init(with str: String) { }
            var body: some View { Text("FR2 type") }
        }
        let expectOnFinish = expectation(description: "OnFinish called")
        let expectedArgs = UUID().uuidString

        let viewUnderTest = try await MainActor.run {
            WorkflowView(isLaunched: .constant(true), launchingWith: expectedArgs) {
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }
                WorkflowItem { (args: String) in FR2(with: args) }
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try viewUnderTest.find(FR1.self).text().string(), "FR1 type")
        try await viewUnderTest.find(FR1.self).proceedInWorkflow(AnyWorkflow.PassedArgs.args(expectedArgs))
        XCTAssertEqual(try viewUnderTest.find(FR2.self).text().string(), "FR2 type")
        try await viewUnderTest.find(FR2.self).proceedInWorkflow()

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    func testWorkflowCanConvertAnyArgsToCorrectTypeForFirstItem() async throws {
        struct FR1: View {
            let data: String

            var body: some View { Text("FR1 type") }

            init(with data: String) {
                self.data = data
            }
        }
        struct FR2: View {
            init(with str: String) { }
            var body: some View { Text("FR2 type") }
        }
        let expectOnFinish = expectation(description: "OnFinish called")
        let expectedArgs = UUID().uuidString

        let viewUnderTest = try await MainActor.run {
            WorkflowView(isLaunched: .constant(true),
                         launchingWith: AnyWorkflow.PassedArgs.args(expectedArgs)) {
                WorkflowItem { (args: String) in FR1(with: args) }
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try viewUnderTest.find(FR1.self).text().string(), "FR1 type")
        XCTAssertEqual(try viewUnderTest.find(FR1.self).actualView().data, expectedArgs)
        try await viewUnderTest.find(FR1.self).proceedInWorkflow()

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    func testWorkflowCanHaveAPassthroughRepresentableInTheMiddle() async throws {
        struct FR1: View {
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View {
            typealias WorkflowOutput = AnyWorkflow.PassedArgs
            private let data: AnyWorkflow.PassedArgs
            var body: some View { Text("FR2 type") }

            init(with data: AnyWorkflow.PassedArgs) {
                self.data = data
            }
        }
        struct FR3: View {
            let str: String
            init(with str: String) {
                self.str = str
            }
            var body: some View { Text("FR3 type, \(str)") }
        }
        let expectOnFinish = expectation(description: "OnFinish called")
        let expectedArgs = UUID().uuidString

        let viewUnderTest = try await MainActor.run {
            WorkflowView(isLaunched: .constant(true)) {
                WorkflowItem { FR1() }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR2(with: args) }
                WorkflowItem { (args: String) in FR3(with: args) }
            }
            .onFinish { _ in
                expectOnFinish.fulfill()
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try viewUnderTest.find(FR1.self).text().string(), "FR1 type")
        try await viewUnderTest.find(FR1.self).proceedInWorkflow()
        XCTAssertEqual(try viewUnderTest.find(FR2.self).text().string(), "FR2 type")
        try await viewUnderTest.find(FR2.self).proceedInWorkflow(AnyWorkflow.PassedArgs.args(expectedArgs))
        XCTAssertEqual(try viewUnderTest.find(FR3.self).text().string(), "FR3 type, \(expectedArgs)")
        try await viewUnderTest.find(FR3.self).proceedInWorkflow()

        wait(for: [expectOnFinish], timeout: TestConstant.timeout)
    }

    #warning("Bring this back?")
//    func testWorkflowCorrectlyHandlesState() async throws {
//        struct FR1: View {
//            weak var _workflowPointer: AnyFlowRepresentable?
//
//            var body: some View {
//                Button("Proceed") { proceedInWorkflow() }
//            }
//        }
//
//        let workflowView = await MainActor.run {
//            WorkflowView(isLaunched: .constant(true)) {
//                WorkflowItem { FR1() }
//            }
//        }
//
//        typealias WorkflowViewContent = State<WorkflowLauncher<WorkflowItemWrapper<WorkflowItem<FR1, FR1>, Never>>>
//        _ = try XCTUnwrap(Mirror(reflecting: workflowView).descendant("_content") as? WorkflowViewContent)
//    }

    func testWorkflowCanHaveADelayedLaunch() async throws {
        struct FR1: View {
            weak var _workflowPointer: AnyFlowRepresentable?

            var body: some View {
                Button("Proceed") { proceedInWorkflow() }
            }
        }

        struct Wrapper: View {
            @State var showingWorkflow = false
            let inspection = Inspection<Self>()
            var body: some View {
                VStack {
                    Button("") { showingWorkflow = true }
                    WorkflowView(isLaunched: $showingWorkflow) {
                        WorkflowItem { FR1() }
                    }
                }
                .onReceive(inspection.notice) { inspection.visit(self, $0) }
            }
        }

        let view = try await MainActor.run { Wrapper() }.hostAndInspect(with: \.inspection)
        let stack = try view.vStack()
        let launcher = try stack.view(WorkflowView<WorkflowItemWrapper<WorkflowItem<FR1>, Never>>.self, 1)

        XCTAssertThrowsError(try launcher.view(WorkflowItemWrapper<WorkflowItem<FR1>, Never>.self))
        XCTAssertNoThrow(try stack.button(0).tap())
        XCTAssertNoThrow(try launcher.view(WorkflowItemWrapper<WorkflowItem<FR1>, Never>.self))
    }

    #warning("Depended on embedInNavigationView")
    func testWorkflowCanBeEmbeddedInNavView() async throws {
        struct FR1: View {
            var body: some View { Text("FR1 type") }
        }
        let viewUnderTest = try await MainActor.run {
            WorkflowView {
                WorkflowItem { FR1() }
            }//.embedInNavigationView()
        }.hostAndInspect(with: \.inspection)

        XCTAssertNoThrow(try viewUnderTest.view(WorkflowItem<FR1>.self).navigationView())
        XCTAssertEqual(try viewUnderTest.find(FR1.self).text().string(), "FR1 type")
    }

    func testWorkflowCanBeLaunched_WithoutArguments_WhenInputIsAnyWorkflowPassedArgs() async throws {
        struct FR1: View {
            typealias WorkflowInput = AnyWorkflow.PassedArgs
            let input: AnyWorkflow.PassedArgs
            init(with args: AnyWorkflow.PassedArgs) {
                input = args
            }

            var body: some View { Text("I'm dropping these args on the flo") }
        }

        let view = try await MainActor.run {
            WorkflowView {
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }
            }
        }.hostAndInspect(with: \.inspection)

        XCTAssertNoThrow(try view.find(FR1.self))
        let input = try view.find(FR1.self).actualView().input
        guard case AnyWorkflow.PassedArgs.none = input else {
            XCTFail("We expected AnyWorkflow.PassedArgs to be .none, but it was \(input)")
            return
        }
    }
}
