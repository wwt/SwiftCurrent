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

import SwiftCurrent

@testable import SwiftCurrent_SwiftUI

extension FlowRepresentable {
    var persistence: FlowPersistence? {
        workflow?.first { item in
            item.value.instance === _workflowPointer
        }?.value.metadata.persistence
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class GenericConstraintTests: XCTestCase {
    // MARK: Generic Initializer Tests

    // MARK: Input Type == Never

    func testWhenInputIsNever_FlowPersistenceCanBeSetWithAutoclosure() {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }

        let workflowView = WorkflowLauncher(isLaunched: .constant(true))
            .thenProceed(with: WorkflowItem(FR1.self).persistence(.persistWhenSkipped))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsNever_FlowPersistenceCanBeSetWithClosure() {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectation = self.expectation(description: "FlowPersistence closure called")
        let workflowView = WorkflowLauncher(isLaunched: .constant(true))
            .thenProceed(with: WorkflowItem(FR1.self).persistence {
                defer { expectation.fulfill() }
                return .persistWhenSkipped
            })

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectation, expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToAnotherNeverItem() throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let workflowView = WorkflowLauncher(isLaunched: .constant(true))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToAnotherNeverItem() throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let workflowView = WorkflowLauncher(isLaunched: .constant(true))
            .thenProceed(with: WorkflowItem(FR1.self).persistence(.persistWhenSkipped))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToAnotherNeverItem() throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let workflowView = WorkflowLauncher(isLaunched: .constant(true))
            .thenProceed(with: WorkflowItem(FR1.self).persistence { .persistWhenSkipped })
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let workflowView = WorkflowLauncher(isLaunched: .constant(true))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let workflowView = WorkflowLauncher(isLaunched: .constant(true))
            .thenProceed(with: WorkflowItem(FR1.self).persistence(.persistWhenSkipped))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR2: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let workflowView = WorkflowLauncher(isLaunched: .constant(true))
            .thenProceed(with: WorkflowItem(FR1.self).persistence { .persistWhenSkipped })
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
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
        let workflowView = WorkflowLauncher(isLaunched: .constant(true))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
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
        let workflowView = WorkflowLauncher(isLaunched: .constant(true))
            .thenProceed(with: WorkflowItem(FR1.self).persistence(.persistWhenSkipped))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
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
        let workflowView = WorkflowLauncher(isLaunched: .constant(true))
            .thenProceed(with: WorkflowItem(FR1.self).persistence { .persistWhenSkipped })
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }


    // MARK: Input Type == AnyWorkflow.PassedArgs

    func testWhenInputIsAnyWorkflowPassedArgs_FlowPersistenceCanBeSetWithAutoclosure() {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self).persistence(.persistWhenSkipped))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsAnyWorkflowPassedArgs_FlowPersistenceCanBeSetWithClosure() {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let expectation = self.expectation(description: "FlowPersistence closure called")
        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self).persistence {
                XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
                defer { expectation.fulfill() }
                return .persistWhenSkipped
            })

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded, expectation], timeout: 0.5)
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToNeverItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToNeverItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self).persistence(.persistWhenSkipped))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToNeverItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self).persistence {
                XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
                return .persistWhenSkipped
            })
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self).persistence(.persistWhenSkipped))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self).persistence {
                XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
                return .persistWhenSkipped
            })
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self).persistence(.persistWhenSkipped))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self).persistence {
                XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
                return .persistWhenSkipped
            })
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    // MARK: Input Type == Concrete Type
    func testWhenInputIsConcreteType_FlowPersistenceCanBeSetWithAutoclosure() {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self).persistence(.persistWhenSkipped))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsConcreteType_FlowPersistenceCanBeSetWithClosure() {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let expectation = self.expectation(description: "FlowPersistence closure called")
        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self).persistence {
                XCTAssertEqual($0, expectedArgs)
                defer { expectation.fulfill() }
                return .persistWhenSkipped
            })

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded, expectation], timeout: 0.5)
    }

    func testWhenInputIsConcreteTypeWithDefaultFlowPersistence_WorkflowCanProceedToNeverItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToNeverItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self).persistence(.persistWhenSkipped))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToNeverItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self).persistence {
                XCTAssertEqual($0, expectedArgs)
                return .persistWhenSkipped
            })
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsConcreteTypeWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self).persistence(.persistWhenSkipped))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self).persistence {
                XCTAssertEqual($0, expectedArgs)
                return .persistWhenSkipped
            })
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsConcreteTypeArgsWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self).persistence(.persistWhenSkipped))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self).persistence {
                XCTAssertEqual($0, expectedArgs)
                return .persistWhenSkipped
            })
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsConcreteTypeArgsWithDefaultFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(""))
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self).persistence(.persistWhenSkipped))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(""))
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR1.self).persistence {
                XCTAssertEqual($0, expectedArgs)
                return .persistWhenSkipped
            })
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(""))
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    // MARK: Generic Proceed Tests

    // MARK: Input Type == Never

    func testProceedingWhenInputIsNever_FlowPersistenceCanBeSetWithAutoclosure() throws {
        struct FR0: PassthroughFlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self).persistence(.persistWhenSkipped))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsNever_FlowPersistenceCanBeSetWithClosure() throws {
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
        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self).persistence {
                defer { expectation.fulfill() }
                return .persistWhenSkipped
            })

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded, expectation], timeout: 0.5)
    }

    func testProceedingWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToAnotherNeverItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToAnotherNeverItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self).persistence(.persistWhenSkipped))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
            XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToAnotherNeverItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self).persistence { .persistWhenSkipped })

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
            XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self).persistence(.persistWhenSkipped))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
            XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self).persistence { _ in .persistWhenSkipped })

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
            XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsNeverWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsNeverWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self).persistence(.persistWhenSkipped))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            XCTAssertNoThrow(try view.find(FR2.self))
            XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsNeverWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self).persistence {
                XCTAssertEqual($0, 1)
                return .persistWhenSkipped
            })

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            XCTAssertNoThrow(try view.find(FR2.self))
            XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }


    // MARK: Input Type == AnyWorkflow.PassedArgs

    func testProceedingWhenInputIsAnyWorkflowPassedArgs_FlowPersistenceCanBeSetWithAutoclosure() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self).persistence(.persistWhenSkipped))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgs_FlowPersistenceCanBeSetWithClosure() throws {
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
        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self).persistence {
                XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
                defer { expectation.fulfill() }
                return .persistWhenSkipped
            })

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded, expectation], timeout: 0.5)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToNeverItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToNeverItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self).persistence(.persistWhenSkipped))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
            XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToNeverItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self).persistence {
                XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
                return .persistWhenSkipped
            }).thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self).persistence(.persistWhenSkipped))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
            XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self).persistence {
                XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
                return .persistWhenSkipped
            })

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
            XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self).persistence(.persistWhenSkipped))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            XCTAssertNoThrow(try view.find(FR2.self))
            XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsAnyWorkflowPassedArgsWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self).persistence {
                XCTAssertEqual($0, 1)
                return .persistWhenSkipped
            })

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            XCTAssertNoThrow(try view.find(FR2.self))
            XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    // MARK: Input Type == Concrete Type
    func testProceedingWhenInputIsConcreteType_FlowPersistenceCanBeSetWithAutoclosure() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self).persistence(.persistWhenSkipped))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsConcreteType_FlowPersistenceCanBeSetWithClosure() throws {
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
        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self).persistence {
                XCTAssertEqual($0, expectedArgs)
                defer { expectation.fulfill() }
                return .persistWhenSkipped
            })

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded, expectation], timeout: 0.5)
    }

    func testProceedingWhenInputIsConcreteTypeWithDefaultFlowPersistence_WorkflowCanProceedToNeverItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToNeverItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self).persistence(.persistWhenSkipped))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
            XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToNeverItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self).persistence { .persistWhenSkipped })

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
            XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsConcreteTypeWithDefaultFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self).persistence(.persistWhenSkipped))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
            XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToAnAnyWorkflowPassedArgsItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self).persistence { _ in .persistWhenSkipped })

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try view.find(FR2.self))
            XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsConcreteTypeArgsWithDefaultFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self).persistence(.persistWhenSkipped))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            XCTAssertNoThrow(try view.find(FR2.self))
            XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToADifferentInputTypeItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self).persistence {
                XCTAssertEqual($0, 1)
                return .persistWhenSkipped
            })

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            XCTAssertNoThrow(try view.find(FR2.self))
            XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsConcreteTypeArgsWithDefaultFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(""))
            XCTAssertNoThrow(try view.find(FR2.self))
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsConcreteTypeWithAutoclosureFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self).persistence(.persistWhenSkipped))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(""))
            XCTAssertNoThrow(try view.find(FR2.self))
            XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToTheSameInputTypeItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self).persistence { _ in .persistWhenSkipped })

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(""))
            XCTAssertNoThrow(try view.find(FR2.self))
            XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }

    func testProceedingWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToAnyWorkflowPassedArgsItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
            .thenProceed(with: WorkflowItem(FR0.self))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self).persistence(.persistWhenSkipped))

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(expectedArgs))
            XCTAssertNoThrow(try view.find(FR2.self))
            XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: 0.5)
    }
}
