//
//  GenericConstraintTests.swift
//  SwiftCurrent_SwiftUITests
//
//  Created by Tyler Thompson on 7/24/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import SwiftUI
import ViewInspector
import UIKit
import SnapshotTesting

import SwiftCurrent

@testable import SwiftCurrent_SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension FlowRepresentable {
    var persistence: FlowPersistence? {
        workflow?.first { item in
            item.value.instance === _workflowPointer
        }?.value.metadata.persistence
    }

    var presentationType: LaunchStyle.SwiftUI.PresentationType? {
        guard let metadata = workflow?.first(where: { item in
            item.value.instance === _workflowPointer
        })?.value.metadata else { return nil }
        return LaunchStyle.SwiftUI.PresentationType(rawValue: metadata.launchStyle)
    }
}

@available(iOS 15.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class GenericConstraintTests: XCTestCase, View {
    // MARK: Generic Initializer Tests

    override func tearDownWithError() throws {
        ViewHosting.expel()
    }

    // MARK: Input Type == Never

    func testWhenInputIsNever_WorkflowCanLaunchWithArguments() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
        }

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: Optional("Discarded arguments")) {
                WorkflowItem { FR1() }
            }
        }.hostAndInspect(with: \.inspection)

        XCTAssertNoThrow(try workflowView.find(FR1.self))
    }

    func testWhenInputIsNeverAndViewDoesNotLoad_WorkflowCanLaunchWithArgumentsAndArgumentsArePassedToTheNextFR() throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: View {
            var body: some View { Text("\(String(describing: Self.self)) INPUT: \(input)") }
            var input: String
            init(with input: String) { self.input = input }
        }
        let expectedArgument = "b8958635-15da-43c9-b70d-ed9d6703a64e"

        let workflowView = WorkflowView(launchingWith: expectedArgument) {
            WorkflowItem { FR1().shouldLoad(false) }
            WorkflowItem { (input: String) in FR2(with: input) }
        }

        assertSnapshot(matching: workflowView, as: .image(on: .iPhone13Pro))
    }

    func testWhenInputIsNever_FlowPersistenceCanBeSetWithAutoclosure() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
        }

        let workflowView = try await MainActor.run {
            TestableWorkflowView {
                WorkflowItem { FR1() }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testWhenInputIsNever_PresentationTypeCanBeSetWithAutoclosure() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
        }

        let workflowView = try await MainActor.run {
            TestableWorkflowView {
                WorkflowItem { FR1() }.presentationType(.navigationLink)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().launchStyle.wrappedValue, .navigationLink)
    }

    func testWhenInputIsNever_FlowPersistenceCanBeSetWithClosure() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectation = self.expectation(description: "FlowPersistence closure called")
        let workflowView = try await MainActor.run {
            WorkflowView {
                WorkflowItem { FR1() }.persistence {
                    defer { expectation.fulfill() }
                    return .removedAfterProceeding
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        wait(for: [expectation], timeout: TestConstant.timeout)
    }

    func testWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToAnotherNeverItem() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        let workflowView = try await MainActor.run {
            TestableWorkflowView {
                WorkflowItem { FR1() }
                WorkflowItem { FR2() }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItemWrapper()

        try await MainActor.run { assertSnapshot(matching: try workflowView.actualView(), as: .image(on: .iPhone13Pro)) }

        XCTAssertNoThrow(try workflowView.find(FR1.self))
        try await workflowView.proceedInWorkflow()
        let view = try await workflowView.actualView().getWrappedView()
        XCTAssertNoThrow(try workflowView.find(type(of: view)).find(FR2.self))
        try await MainActor.run { assertSnapshot(matching: try workflowView.actualView(), as: .image(on: .iPhone13Pro)) }
    }

    func testWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToAnotherNeverItem() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        let workflowView = try await MainActor.run {
            WorkflowView {
                WorkflowItem { FR1() }.persistence(.removedAfterProceeding)
                WorkflowItem { FR2() }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToAnotherNeverItem() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        let workflowView = try await MainActor.run {
            WorkflowView {
                WorkflowItem { FR1() }.persistence { .removedAfterProceeding }
                WorkflowItem { FR2() }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let workflowView = try await MainActor.run {
            TestableWorkflowView {
                WorkflowItem { FR1() }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItemWrapper()

        XCTAssertNoThrow(try workflowView.find(FR1.self))
        try await workflowView.proceedInWorkflow()
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let workflowView = try await MainActor.run {
            WorkflowView {
                WorkflowItem { FR1() }.persistence(.removedAfterProceeding)
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let workflowView = try await MainActor.run {
            WorkflowView {
                WorkflowItem { FR1() }.persistence { .removedAfterProceeding }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR1: View {
            typealias WorkflowOutput = Int
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let workflowView = try await MainActor.run {
            TestableWorkflowView {
                WorkflowItem { FR1() }
                WorkflowItem { (args: Int) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItemWrapper()

        XCTAssertNoThrow(try workflowView.find(FR1.self))
        try await workflowView.proceedInWorkflow(1)
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR1: View {
            typealias WorkflowOutput = Int
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let workflowView = try await MainActor.run {
            WorkflowView {
                WorkflowItem { FR1() }.persistence(.removedAfterProceeding)
                WorkflowItem { (args: Int) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow(1)
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR1: View {
            typealias WorkflowOutput = Int
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let workflowView = try await MainActor.run {
            WorkflowView {
                WorkflowItem { FR1() }.persistence { .removedAfterProceeding }
                WorkflowItem { (args: Int) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow(1)
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    // MARK: Input Type == AnyWorkflow.PassedArgs

    func testWhenInputIsAnyWorkflowPassedArgs_FlowPersistenceCanBeSetWithAutoclosure() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testWhenInputIsAnyWorkflowPassedArgs_PresentationTypeCanBeSetWithAutoclosure() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }.presentationType(.navigationLink)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().launchStyle.wrappedValue, .navigationLink)
    }

    func testWhenInputIsAnyWorkflowPassedArgs_FlowPersistenceCanBeSetWithClosure() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let expectation = self.expectation(description: "FlowPersistence closure called")
        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }.persistence {
                    defer { expectation.fulfill() }
                    return .removedAfterProceeding
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        wait(for: [expectation], timeout: TestConstant.timeout)
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }
                WorkflowItem { FR2() }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }.persistence(.removedAfterProceeding)
                WorkflowItem { FR2() }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }.persistence {
                    return .removedAfterProceeding
                }
                WorkflowItem { FR2() }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }.persistence(.removedAfterProceeding)
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }.persistence {
                    return .removedAfterProceeding
                }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR1: View {
            typealias WorkflowOutput = Int
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }
                WorkflowItem { (args: Int) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR1.self).proceedInWorkflow(1)
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR1: View {
            typealias WorkflowOutput = Int
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }.persistence(.removedAfterProceeding)
                WorkflowItem { (args: Int) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow(1)
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR1: View {
            typealias WorkflowOutput = Int
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }.persistence {
                    return .removedAfterProceeding
                }
                WorkflowItem { (args: Int) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow(1)
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    // MARK: Input Type == Concrete Type
    func testWhenInputIsConcreteType_FlowPersistenceCanBeSetWithAutoclosure() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: String) in FR1(with: args) }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testWhenInputIsConcreteType_PresentationTypeCanBeSetWithAutoclosure() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: String) in FR1(with: args) }.presentationType(.navigationLink)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().launchStyle.wrappedValue, .navigationLink)
    }

    func testWhenInputIsConcreteType_FlowPersistenceCanBeSetWithClosure() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let expectation = self.expectation(description: "FlowPersistence closure called")
        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: String) in FR1(with: args) }.persistence {
                    defer { expectation.fulfill() }
                    return .removedAfterProceeding
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        wait(for: [expectation], timeout: TestConstant.timeout)
    }

    func testWhenInputIsConcreteTypeWithDefaultFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: String) in FR1(with: args) }
                WorkflowItem { FR2() }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: String) in FR1(with: args) }.persistence(.removedAfterProceeding)
                WorkflowItem { FR2() }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: String) in FR1(with: args) }.persistence {
                    return .removedAfterProceeding
                }
                WorkflowItem { FR2() }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsConcreteTypeWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: String) in FR1(with: args) }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: String) in FR1(with: args) }.persistence(.removedAfterProceeding)
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: String) in FR1(with: args) }.persistence {
                    return .removedAfterProceeding
                }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsConcreteTypeArgsWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR1: View {
            typealias WorkflowOutput = Int
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: String) in FR1(with: args) }
                WorkflowItem { (args: Int) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR1.self).proceedInWorkflow(1)
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR1: View {
            typealias WorkflowOutput = Int
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: String) in FR1(with: args) }.persistence(.removedAfterProceeding)
                WorkflowItem { (args: Int) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow(1)
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR1: View {
            typealias WorkflowOutput = Int
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: String) in FR1(with: args) }.persistence {
                    return .removedAfterProceeding
                }
                WorkflowItem { (args: Int) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow(1)
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsConcreteTypeArgsWithDefaultFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() async throws {
        struct FR1: View {
            typealias WorkflowOutput = String
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: String) in FR1(with: args) }
                WorkflowItem { (args: String) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR1.self).proceedInWorkflow("")
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() async throws {
        struct FR1: View {
            typealias WorkflowOutput = String
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: String) in FR1(with: args) }.persistence(.removedAfterProceeding)
                WorkflowItem { (args: String) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow("")
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() async throws {
        struct FR1: View {
            typealias WorkflowOutput = String
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { (args: String) in FR1(with: args) }.persistence {
                    return .removedAfterProceeding
                }
                WorkflowItem { (args: String) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow("")
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    // MARK: Generic Proceed Tests

    // MARK: Input Type == Never

    func testProceedingWhenInputIsNever_FlowPersistenceCanBeSetWithAutoclosure() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { FR1() }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertEqual(try view.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsNever_FlowPersistenceCanBeSetWithClosure() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let expectation = self.expectation(description: "FlowPersistence closure called")
        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { FR1() }.persistence {
                    defer { expectation.fulfill() }
                    return .removedAfterProceeding
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertEqual(try view.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        wait(for: [expectation], timeout: TestConstant.timeout)
    }

    func testProceedingWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToAnotherNeverItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { FR1() }
                WorkflowItem { FR2() }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()

        let workflowItem = try await workflowView.extractWrappedWrapper()
        try await workflowItem.find(FR1.self).proceedInWorkflow()

        let view = try await workflowItem.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testProceedingWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToAnotherNeverItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { FR1() }
                WorkflowItem { FR2() }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let workflowItem = try await workflowView.extractWrappedWrapper()
        try await workflowItem.find(FR1.self).proceedInWorkflow()
        let view = try await workflowItem.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
        XCTAssertEqual(try view.find(WorkflowItem<FR2>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToAnotherNeverItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { FR1() }
                WorkflowItem { FR2() }.persistence { .removedAfterProceeding }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let workflowItem = try await workflowView.extractWrappedWrapper()
        try await workflowItem.find(FR1.self).proceedInWorkflow()
        let view = try await workflowItem.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
        XCTAssertEqual(try view.find(WorkflowItem<FR2>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { FR1() }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let workflowItem = try await workflowView.extractWrappedWrapper()
        try await workflowItem.find(FR1.self).proceedInWorkflow()
        let view = try await workflowItem.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testProceedingWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { FR1() }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR2(with: args) }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let workflowItem = try await workflowView.extractWrappedWrapper()
        try await workflowItem.find(FR1.self).proceedInWorkflow()
        let view = try await workflowItem.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
        XCTAssertEqual(try view.find(WorkflowItem<FR2>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { FR1() }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR2(with: args) }.persistence { .removedAfterProceeding }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let workflowItem = try await workflowView.extractWrappedWrapper()
        try await workflowItem.find(FR1.self).proceedInWorkflow()

        let view = try await workflowItem.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
        XCTAssertEqual(try view.find(WorkflowItem<FR2>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            typealias WorkflowOutput = Int
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { FR1() }
                WorkflowItem { (args: Int) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let workflowItem = try await workflowView.extractWrappedWrapper()
        try await workflowItem.find(FR1.self).proceedInWorkflow(1)
        let view = try await workflowItem.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testProceedingWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            typealias WorkflowOutput = Int
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { FR1() }
                WorkflowItem { (args: Int) in FR2(with: args) }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let workflowItem = try await workflowView.extractWrappedWrapper()
        try await workflowItem.find(FR1.self).proceedInWorkflow(1)
        let view = try await workflowItem.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
        XCTAssertEqual(try view.find(WorkflowItem<FR2>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            typealias WorkflowOutput = Int
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { FR1() }
                WorkflowItem { (args: Int) in FR2(with: args) }.persistence {
                    return .removedAfterProceeding
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let workflowItem = try await workflowView.extractWrappedWrapper()
        try await workflowItem.find(FR1.self).proceedInWorkflow(1)
        let view = try await workflowItem.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
        XCTAssertEqual(try view.find(WorkflowItem<FR2>.self).actualView().persistence, .removedAfterProceeding)
    }


    // MARK: Input Type == AnyWorkflow.PassedArgs

    func testProceedingWhenInputIsAnyWorkflowPassedArgs_FlowPersistenceCanBeSetWithAutoclosure() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        XCTAssertEqual(try workflowView.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgs_FlowPersistenceCanBeSetWithClosure() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let expectation = self.expectation(description: "FlowPersistence closure called")
        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }.persistence {
                    defer { expectation.fulfill() }
                    return .removedAfterProceeding
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertEqual(try view.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        wait(for: [expectation], timeout: TestConstant.timeout)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }
                WorkflowItem { FR2() }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let workflowItem = try await workflowView.extractWrappedWrapper()
        try await workflowItem.find(FR1.self).proceedInWorkflow()
        let view = try await workflowItem.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }
                WorkflowItem { FR2() }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let workflowItem = try await workflowView.extractWrappedWrapper()
        try await workflowItem.find(FR1.self).proceedInWorkflow()
        let view = try await workflowItem.extractWrappedWrapper()
        XCTAssertNoThrow(try view.find(FR2.self))
        XCTAssertEqual(try view.find(WorkflowItem<FR2>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }.persistence {
                    return .removedAfterProceeding
                }
                WorkflowItem { FR2() }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWrapper()
        XCTAssertEqual(try wfr1.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        try await wfr1.find(FR1.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWrapper()
        try await wfr1.find(FR1.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR2(with: args) }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWrapper()
        try await wfr1.find(FR1.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(WorkflowItem<FR2>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR2(with: args) }.persistence {
                    return .removedAfterProceeding
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWrapper()
        try await wfr1.find(FR1.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(WorkflowItem<FR2>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            typealias WorkflowOutput = Int
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }
                WorkflowItem { (args: Int) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWrapper()
        try await wfr1.find(FR1.self).proceedInWorkflow(1)
        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            typealias WorkflowOutput = Int
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }
                WorkflowItem { (args: Int) in FR2(with: args) }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWrapper()
        try await wfr1.find(FR1.self).proceedInWorkflow(1)
        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(WorkflowItem<FR2>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            typealias WorkflowOutput = Int
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR1(with: args) }
                WorkflowItem { (args: Int) in FR2(with: args) }.persistence {
                    return .removedAfterProceeding
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWrapper()
        try await wfr1.find(FR1.self).proceedInWorkflow(1)
        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(WorkflowItem<FR2>.self).actualView().persistence, .removedAfterProceeding)
    }

    // MARK: Input Type == Concrete Type
    func testCreatingMalformedWorkflowWithMismatchingConcreteTypes() throws {
        struct FR0: View {
            typealias WorkflowOutput = Int
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }

        try XCTAssertThrowsFatalError {
            _ = WorkflowView {
                WorkflowItem { FR0() }
                WorkflowItem { (args: String) in FR1(with: args) }.persistence(.removedAfterProceeding)
            }
        }
    }

    func testProceedingWhenInputIsConcreteType_FlowPersistenceCanBeSetWithAutoclosure() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: String) in FR1(with: args) }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertEqual(try view.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsConcreteType_FlowPersistenceCanBeSetWithClosure() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let expectation = self.expectation(description: "FlowPersistence closure called")
        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: String) in FR1(with: args) }.persistence {
                    defer { expectation.fulfill() }
                    return .removedAfterProceeding
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWrapper()
        XCTAssertEqual(try view.find(WorkflowItem<FR1>.self).actualView().persistence, .removedAfterProceeding)
        wait(for: [expectation], timeout: TestConstant.timeout)
    }

    func testProceedingWhenInputIsConcreteTypeWithDefaultFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: String) in FR1(with: args) }
                WorkflowItem { FR2() }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWrapper()
        try await wfr1.find(FR1.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
    }

    func testProceedingWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: String) in FR1(with: args) }
                WorkflowItem { FR2() }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWrapper()
        try await wfr1.find(FR1.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(WorkflowItem<FR2>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: String) in FR1(with: args) }
                WorkflowItem { FR2() }.persistence { .removedAfterProceeding }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWrapper()
        try await wfr1.find(FR1.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(WorkflowItem<FR2>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsConcreteTypeWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: String) in FR1(with: args) }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWrapper()
        try await wfr1.find(FR1.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
    }

    func testProceedingWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: String) in FR1(with: args) }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR2(with: args) }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWrapper()
        try await wfr1.find(FR1.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(WorkflowItem<FR2>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: String) in FR1(with: args) }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR2(with: args) }.persistence { .removedAfterProceeding }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWrapper()
        try await wfr1.find(FR1.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(WorkflowItem<FR2>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsConcreteTypeArgsWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            typealias WorkflowOutput = Int
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: String) in FR1(with: args) }
                WorkflowItem { (args: Int) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWrapper()
        try await wfr1.find(FR1.self).proceedInWorkflow(1)
        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
    }

    func testProceedingWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            typealias WorkflowOutput = Int
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: String) in FR1(with: args) }
                WorkflowItem { (args: Int) in FR2(with: args) }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWrapper()
        try await wfr1.find(FR1.self).proceedInWorkflow(1)
        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(WorkflowItem<FR2>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            typealias WorkflowOutput = Int
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: String) in FR1(with: args) }
                WorkflowItem { (args: Int) in FR2(with: args) }.persistence {
                    return .removedAfterProceeding
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWrapper()
        try await wfr1.find(FR1.self).proceedInWorkflow(1)
        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(WorkflowItem<FR2>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsConcreteTypeArgsWithDefaultFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            typealias WorkflowOutput = String
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: String) in FR1(with: args) }
                WorkflowItem { (args: String) in FR2(with: args) }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWrapper()
        try await wfr1.find(FR1.self).proceedInWorkflow("")
        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
    }

    func testProceedingWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            typealias WorkflowOutput = String
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: String) in FR1(with: args) }
                WorkflowItem { (args: String) in FR2(with: args) }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWrapper()
        try await wfr1.find(FR1.self).proceedInWorkflow("")
        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(WorkflowItem<FR2>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            typealias WorkflowOutput = String
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: String) in FR1(with: args) }
                WorkflowItem { (args: String) in FR2(with: args) }.persistence { .removedAfterProceeding }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWrapper()
        try await wfr1.find(FR1.self).proceedInWorkflow("")
        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(WorkflowItem<FR2>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToAnyWorkflowPassedArgsItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            typealias WorkflowOutput = String
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: String) in FR1(with: args) }
                WorkflowItem { (args: AnyWorkflow.PassedArgs) in FR2(with: args) }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWrapper()
        try await wfr1.find(FR1.self).proceedInWorkflow(expectedArgs)
        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(WorkflowItem<FR2>.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingTwiceWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            typealias WorkflowOutput = String
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: String) in FR1(with: args) }
                WorkflowItem { FR2() }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWrapper()
        try await wfr1.find(FR1.self).proceedInWorkflow(expectedArgs)
        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(WorkflowItem<FR2>.self).actualView().persistence, .removedAfterProceeding)
    }

    #warning("FINDME! Need to re-enable after we figure out UIKit interop")
//    func testThenProceedFunctions_WithUIViewControllers_AsExpectedOnView() async throws {
//        final class FR0: UIViewController, FlowRepresentable {
//            weak var _workflowPointer: AnyFlowRepresentable?
//        }
//
//        final class FR1: UIViewController, FlowRepresentable {
//            weak var _workflowPointer: AnyFlowRepresentable?
//        }
//
//        final class FR2: UIViewController, FlowRepresentable {
//            weak var _workflowPointer: AnyFlowRepresentable?
//        }
//
//        let workflowView = try await MainActor.run {
//            WorkflowView {
//                WorkflowItem { FR0() }
//                WorkflowItem { FR1() }
//                WorkflowItem { FR2() }
//            }
//        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()
//
//        try await workflowView.find(ViewControllerWrapper<FR0>.self).proceedInWorkflow()
//        let wfr1 = try await workflowView.extractWrappedWrapper()
//        try await wfr1.find(ViewControllerWrapper<FR1>.self).proceedInWorkflow()
//        let wfr2 = try await wfr1.extractWrappedWrapper()
//        XCTAssertNoThrow(try wfr2.find(ViewControllerWrapper<FR2>.self))
//    }
}

@available(iOS 15, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class ThenProceedOnAppTests: XCTestCase {
    func testThenProceedFunctionsAsExpectedOnApp() async throws {
        struct FR0: View { // Passthrough
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            typealias WorkflowOutput = String
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: String) in FR1(with: args) }
                WorkflowItem { (args: String) in FR2(with: args) }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWrapper()
        try await wfr1.find(FR1.self).proceedInWorkflow("")
        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(WorkflowItem<FR2>.self).actualView().persistence, .removedAfterProceeding)
    }

    #warning("FINDME, UIKit stuff")
//    func testThenProceedFunctions_WithUIViewControllers_AsExpectedOnApp() async throws {
//        final class FR0: UIViewController, FlowRepresentable {
//            weak var _workflowPointer: AnyFlowRepresentable?
//        }
//
//        final class FR1: UIViewController, FlowRepresentable {
//            weak var _workflowPointer: AnyFlowRepresentable?
//        }
//
//        final class FR2: UIViewController, FlowRepresentable {
//            weak var _workflowPointer: AnyFlowRepresentable?
//        }
//
//        let workflowView = try await MainActor.run {
//            WorkflowView {
//                WorkflowItem { FR0() }
//                WorkflowItem { FR1() }
//                WorkflowItem { FR2() }
//            }
//        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()
//
//        try await workflowView.find(ViewControllerWrapper<FR0>.self).proceedInWorkflow()
//        let wfr1 = try await workflowView.extractWrappedWrapper()
//        try await wfr1.find(ViewControllerWrapper<FR1>.self).proceedInWorkflow()
//        let wfr2 = try await wfr1.extractWrappedWrapper()
//        XCTAssertNoThrow(try wfr2.find(ViewControllerWrapper<FR2>.self))
//    }
}

@available(iOS 15.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class ThenProceedOnSceneTests: XCTestCase, Scene {
    func testThenProceedFunctionsAsExpectedOnScene() async throws {
        struct FR0: View {
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: View {
            typealias WorkflowOutput = String
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: View {
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowView(launchingWith: expectedArgs) {
                WorkflowItem { FR0() }
                WorkflowItem { (args: String) in FR1(with: args) }
                WorkflowItem { (args: String) in FR2(with: args) }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWrapper()
        try await wfr1.find(FR1.self).proceedInWorkflow("")
        let wfr2 = try await wfr1.extractWrappedWrapper()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(WorkflowItem<FR2>.self).actualView().persistence, .removedAfterProceeding)
    }

    #warning("FINDME, UIKit stuff")
//    func testThenProceedFunctions_WithUIViewControllers_AsExpectedOnScene() async throws {
//        final class FR0: UIViewController, FlowRepresentable {
//            weak var _workflowPointer: AnyFlowRepresentable?
//        }
//
//        final class FR1: UIViewController, FlowRepresentable {
//            weak var _workflowPointer: AnyFlowRepresentable?
//        }
//
//        final class FR2: UIViewController, FlowRepresentable {
//            weak var _workflowPointer: AnyFlowRepresentable?
//        }
//
//        let workflowView = try await MainActor.run {
//            WorkflowView {
//                WorkflowItem { FR0() }
//                WorkflowItem { FR1() }
//                WorkflowItem { FR2() }
//            }
//        }.hostAndInspect(with: \.inspection).extractWorkflowLauncher().extractWorkflowItemWrapper()
//
//        try await workflowView.find(ViewControllerWrapper<FR0>.self).proceedInWorkflow()
//        let wfr1 = try await workflowView.extractWrappedWrapper()
//        try await wfr1.find(ViewControllerWrapper<FR1>.self).proceedInWorkflow()
//        let wfr2 = try await wfr1.extractWrappedWrapper()
//        XCTAssertNoThrow(try wfr2.find(ViewControllerWrapper<FR2>.self))
//    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension View {
    func proceedInWorkflow() {
        XCTFail("Cannot proceed like this, womp womp")
    }
}
