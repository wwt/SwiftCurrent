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

    // MARK: Input Type == Never

    func testWhenInputIsNever_WorkflowCanLaunchWithArguments() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            weak var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: Optional("Discarded arguments")) {
                thenProceed(with: FR1.self)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertNoThrow(try workflowView.find(FR1.self))
    }

    func testWhenInputIsNeverAndViewDoesNotLoad_WorkflowCanLaunchWithArgumentsAndArgumentsArePassedToTheNextFR() async throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            typealias WorkflowOutput = String
            weak var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            func shouldLoad() -> Bool { false }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            weak var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            var input: String
            init(with input: String) { self.input = input }
        }
        let expectedArgument = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgument) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR2.self).actualView().input, expectedArgument)
    }

    func testWhenInputIsNever_FlowPersistenceCanBeSetWithAutoclosure() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self).persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
    }

    func testWhenInputIsNever_PresentationTypeCanBeSetWithAutoclosure() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self).presentationType(.navigationLink)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().presentationType, .navigationLink)
    }

    func testWhenInputIsNever_FlowPersistenceCanBeSetWithClosure() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectation = self.expectation(description: "FlowPersistence closure called")
        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self).persistence {
                    defer { expectation.fulfill() }
                    return .removedAfterProceeding
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        wait(for: [expectation], timeout: TestConstant.timeout)
    }

    func testWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToAnotherNeverItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.actualView().getWrappedView()
        XCTAssertNoThrow(try workflowView.find(type(of: view)).find(FR2.self))
    }

    func testWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToAnotherNeverItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToAnotherNeverItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }.persistence { .removedAfterProceeding }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }.persistence { .removedAfterProceeding }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR1.self).proceedInWorkflow(1)
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow(1)
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }.persistence { .removedAfterProceeding }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow(1)
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    // MARK: Input Type == AnyWorkflow.PassedArgs

    func testWhenInputIsAnyWorkflowPassedArgs_FlowPersistenceCanBeSetWithAutoclosure() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self).persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
    }

    func testWhenInputIsAnyWorkflowPassedArgs_PresentationTypeCanBeSetWithAutoclosure() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self).presentationType(.navigationLink)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().presentationType, .navigationLink)
    }

    func testWhenInputIsAnyWorkflowPassedArgs_FlowPersistenceCanBeSetWithClosure() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let expectation = self.expectation(description: "FlowPersistence closure called")
        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self).persistence {
                    XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
                    defer { expectation.fulfill() }
                    return .removedAfterProceeding
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        wait(for: [expectation], timeout: TestConstant.timeout)
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }.persistence {
                    XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
                    return .removedAfterProceeding
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }.persistence {
                    XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
                    return .removedAfterProceeding
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR1.self).proceedInWorkflow(1)
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow(1)
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }.persistence {
                    XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
                    return .removedAfterProceeding
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow(1)
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    // MARK: Input Type == Concrete Type
    func testWhenInputIsConcreteType_FlowPersistenceCanBeSetWithAutoclosure() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self).persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
    }

    func testWhenInputIsConcreteType_PresentationTypeCanBeSetWithAutoclosure() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self).presentationType(.navigationLink)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().presentationType, .navigationLink)
    }

    func testWhenInputIsConcreteType_FlowPersistenceCanBeSetWithClosure() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let expectation = self.expectation(description: "FlowPersistence closure called")
        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self).persistence {
                    XCTAssertEqual($0, expectedArgs)
                    defer { expectation.fulfill() }
                    return .removedAfterProceeding
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        wait(for: [expectation], timeout: TestConstant.timeout)
    }

    func testWhenInputIsConcreteTypeWithDefaultFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }.persistence {
                    XCTAssertEqual($0, expectedArgs)
                    return .removedAfterProceeding
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsConcreteTypeWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }.persistence {
                    XCTAssertEqual($0, expectedArgs)
                    return .removedAfterProceeding
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsConcreteTypeArgsWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR1.self).proceedInWorkflow(1)
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow(1)
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }.persistence {
                    XCTAssertEqual($0, expectedArgs)
                    return .removedAfterProceeding
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow(1)
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsConcreteTypeArgsWithDefaultFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = String
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR1.self).proceedInWorkflow("")
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = String
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }.persistence(.removedAfterProceeding)
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow("")
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() async throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = String
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }.persistence {
                    XCTAssertEqual($0, expectedArgs)
                    return .removedAfterProceeding
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        try await workflowView.find(FR1.self).proceedInWorkflow("")
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    // MARK: Generic Proceed Tests

    // MARK: Input Type == Never

    func testProceedingWhenInputIsNever_FlowPersistenceCanBeSetWithAutoclosure() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self).persistence(.removedAfterProceeding)
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsNever_FlowPersistenceCanBeSetWithClosure() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let expectation = self.expectation(description: "FlowPersistence closure called")
        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self).persistence {
                        defer { expectation.fulfill() }
                        return .removedAfterProceeding
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        wait(for: [expectation], timeout: TestConstant.timeout)
    }

    func testProceedingWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToAnotherNeverItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()

        let workflowItem = try await workflowView.extractWrappedWorkflowItem()

        try await workflowItem.find(FR1.self).proceedInWorkflow()

        let view = try await workflowItem.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testProceedingWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToAnotherNeverItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self).persistence(.removedAfterProceeding)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let workflowItem = try await workflowView.extractWrappedWorkflowItem()
        try await workflowItem.find(FR1.self).proceedInWorkflow()
        let view = try await workflowItem.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
        XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToAnotherNeverItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self).persistence { .removedAfterProceeding }
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let workflowItem = try await workflowView.extractWrappedWorkflowItem()
        try await workflowItem.find(FR1.self).proceedInWorkflow()
        let view = try await workflowItem.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
        XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let workflowItem = try await workflowView.extractWrappedWorkflowItem()
        try await workflowItem.find(FR1.self).proceedInWorkflow()
        let view = try await workflowItem.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testProceedingWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self).persistence(.removedAfterProceeding)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let workflowItem = try await workflowView.extractWrappedWorkflowItem()
        try await workflowItem.find(FR1.self).proceedInWorkflow()
        let view = try await workflowItem.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
        XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self).persistence { _ in .removedAfterProceeding }
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let workflowItem = try await workflowView.extractWrappedWorkflowItem()
        try await workflowItem.find(FR1.self).proceedInWorkflow()

        let view = try await workflowItem.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
        XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = Int
            var body: some View { Text(String(describing: Self.self)) }
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let workflowItem = try await workflowView.extractWrappedWorkflowItem()
        try await workflowItem.find(FR1.self).proceedInWorkflow(1)
        let view = try await workflowItem.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testProceedingWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = Int
            var body: some View { Text(String(describing: Self.self)) }
            var _workflowPointer: AnyFlowRepresentable?
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self).persistence(.removedAfterProceeding)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let workflowItem = try await workflowView.extractWrappedWorkflowItem()
        try await workflowItem.find(FR1.self).proceedInWorkflow(1)
        let view = try await workflowItem.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
        XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self).persistence {
                            XCTAssertEqual($0, 1)
                            return .removedAfterProceeding
                        }
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let workflowItem = try await workflowView.extractWrappedWorkflowItem()
        try await workflowItem.find(FR1.self).proceedInWorkflow(1)
        let view = try await workflowItem.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
        XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .removedAfterProceeding)
    }


    // MARK: Input Type == AnyWorkflow.PassedArgs

    func testProceedingWhenInputIsAnyWorkflowPassedArgs_FlowPersistenceCanBeSetWithAutoclosure() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self).persistence(.removedAfterProceeding)
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        XCTAssertEqual(try workflowView.find(FR1.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgs_FlowPersistenceCanBeSetWithClosure() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let expectation = self.expectation(description: "FlowPersistence closure called")
        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self).persistence {
                        XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
                        defer { expectation.fulfill() }
                        return .removedAfterProceeding
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        wait(for: [expectation], timeout: TestConstant.timeout)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let workflowItem = try await workflowView.extractWrappedWorkflowItem()
        try await workflowItem.find(FR1.self).proceedInWorkflow()
        let view = try await workflowItem.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self).persistence(.removedAfterProceeding)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let workflowItem = try await workflowView.extractWrappedWorkflowItem()
        try await workflowItem.find(FR1.self).proceedInWorkflow()
        let view = try await workflowItem.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try view.find(FR2.self))
        XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self)
                    }.persistence {
                        XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
                        return .removedAfterProceeding
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertEqual(try wfr1.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        try await wfr1.find(FR1.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(FR1.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self).persistence(.removedAfterProceeding)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(FR1.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(FR2.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self).persistence {
                            XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
                            return .removedAfterProceeding
                        }
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(FR1.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(FR2.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(FR1.self).proceedInWorkflow(1)
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self).persistence(.removedAfterProceeding)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(FR1.self).proceedInWorkflow(1)
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(FR2.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self).persistence {
                            XCTAssertEqual($0, 1)
                            return .removedAfterProceeding
                        }
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(FR1.self).proceedInWorkflow(1)
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(FR2.self).actualView().persistence, .removedAfterProceeding)
    }

    // MARK: Input Type == Concrete Type
    func testCreatingMalformedWorkflowWithMismatchingConcreteTypes() throws {
        struct FR0: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }

        try XCTAssertThrowsFatalError {
            _ = WorkflowLauncher(isLaunched: .constant(true)) {
                self.thenProceed(with: FR0.self) {
                    self.thenProceed(with: FR1.self).persistence(.removedAfterProceeding)
                }
            }
        }
    }

    func testProceedingWhenInputIsConcreteType_FlowPersistenceCanBeSetWithAutoclosure() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self).persistence(.removedAfterProceeding)
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsConcreteType_FlowPersistenceCanBeSetWithClosure() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let expectation = self.expectation(description: "FlowPersistence closure called")
        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self).persistence {
                        XCTAssertEqual($0, expectedArgs)
                        defer { expectation.fulfill() }
                        return .removedAfterProceeding
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let view = try await workflowView.extractWrappedWorkflowItem()
        XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .removedAfterProceeding)
        wait(for: [expectation], timeout: TestConstant.timeout)
    }

    func testProceedingWhenInputIsConcreteTypeWithDefaultFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(FR1.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
    }

    func testProceedingWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self).persistence(.removedAfterProceeding)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(FR1.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(FR2.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self).persistence { .removedAfterProceeding }
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(FR1.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(FR2.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsConcreteTypeWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(FR1.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
    }

    func testProceedingWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self).persistence(.removedAfterProceeding)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(FR1.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(FR2.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self).persistence { _ in .removedAfterProceeding }
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(FR1.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(FR2.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsConcreteTypeArgsWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(FR1.self).proceedInWorkflow(1)
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
    }

    func testProceedingWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self).persistence(.removedAfterProceeding)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(FR1.self).proceedInWorkflow(1)
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(FR2.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = Int
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: Int) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self).persistence {
                            XCTAssertEqual($0, 1)
                            return .removedAfterProceeding
                        }
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(FR1.self).proceedInWorkflow(1)
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(FR2.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsConcreteTypeArgsWithDefaultFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = String
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(FR1.self).proceedInWorkflow("")
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
    }

    func testProceedingWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = String
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self).persistence(.removedAfterProceeding)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(FR1.self).proceedInWorkflow("")
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(FR2.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = String
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self).persistence { _ in .removedAfterProceeding }
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(FR1.self).proceedInWorkflow("")
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(FR2.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToAnyWorkflowPassedArgsItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = String
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self).persistence(.removedAfterProceeding)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(FR1.self).proceedInWorkflow(expectedArgs)
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(FR2.self).actualView().persistence, .removedAfterProceeding)
    }

    func testProceedingTwiceWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToNeverItem() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = String
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self).persistence(.removedAfterProceeding)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(FR1.self).proceedInWorkflow(expectedArgs)
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(FR2.self).actualView().persistence, .removedAfterProceeding)
    }

    func testThenProceedFunctions_WithUIViewControllers_AsExpectedOnView() async throws {
        final class FR0: UIViewController, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        final class FR1: UIViewController, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        final class FR2: UIViewController, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(ViewControllerWrapper<FR0>.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(ViewControllerWrapper<FR1>.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(ViewControllerWrapper<FR2>.self))
    }
}

@available(iOS 15, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class ThenProceedOnAppTests: XCTestCase, App {
    func testThenProceedFunctionsAsExpectedOnApp() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = String
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self).persistence(.removedAfterProceeding)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(FR1.self).proceedInWorkflow("")
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(FR2.self).actualView().persistence, .removedAfterProceeding)
    }

    func testThenProceedFunctions_WithUIViewControllers_AsExpectedOnApp() async throws {
        final class FR0: UIViewController, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        final class FR1: UIViewController, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        final class FR2: UIViewController, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(ViewControllerWrapper<FR0>.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(ViewControllerWrapper<FR1>.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(ViewControllerWrapper<FR2>.self))
    }
}

@available(iOS 15.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class ThenProceedOnSceneTests: XCTestCase, Scene {
    func testThenProceedFunctionsAsExpectedOnScene() async throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            typealias WorkflowOutput = String
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self).persistence(.removedAfterProceeding)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(FR0.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(FR1.self).proceedInWorkflow("")
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(FR2.self))
        XCTAssertEqual(try wfr2.find(FR2.self).actualView().persistence, .removedAfterProceeding)
    }

    func testThenProceedFunctions_WithUIViewControllers_AsExpectedOnScene() async throws {
        final class FR0: UIViewController, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        final class FR1: UIViewController, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        final class FR2: UIViewController, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?
        }

        let workflowView = try await MainActor.run {
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR0.self) {
                    thenProceed(with: FR1.self) {
                        thenProceed(with: FR2.self)
                    }
                }
            }
        }.hostAndInspect(with: \.inspection).extractWorkflowItem()

        try await workflowView.find(ViewControllerWrapper<FR0>.self).proceedInWorkflow()
        let wfr1 = try await workflowView.extractWrappedWorkflowItem()
        try await wfr1.find(ViewControllerWrapper<FR1>.self).proceedInWorkflow()
        let wfr2 = try await wfr1.extractWrappedWorkflowItem()
        XCTAssertNoThrow(try wfr2.find(ViewControllerWrapper<FR2>.self))
    }
}
