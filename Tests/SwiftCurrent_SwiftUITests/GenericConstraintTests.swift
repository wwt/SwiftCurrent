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

    var presentationType: LaunchStyle.SwiftUI.PresentationType? {
        guard let metadata = workflow?.first(where: { item in
            item.value.instance === _workflowPointer
        })?.value.metadata else { return nil }
        return LaunchStyle.SwiftUI.PresentationType(rawValue: metadata.launchStyle)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class GenericConstraintTests: XCTestCase, View {
    override func tearDownWithError() throws {
        removeQueuedExpectations()
    }

    // MARK: Generic Initializer Tests

    // MARK: Input Type == Never

    func testWhenInputIsNever_FlowPersistenceCanBeSetWithAutoclosure() {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }

        let workflowView = WorkflowLauncher(isLaunched: .constant(true)) {
            thenProceed(with: FR1.self).persistence(.persistWhenSkipped)
        }

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testWhenInputIsNever_PresentationTypeCanBeSetWithAutoclosure() {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }

        let workflowView = WorkflowLauncher(isLaunched: .constant(true)) {
            thenProceed(with: FR1.self).presentationType(.navigationLink)
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().presentationType, .navigationLink)
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testWhenInputIsNever_FlowPersistenceCanBeSetWithClosure() {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }
        let expectation = self.expectation(description: "FlowPersistence closure called")
        let workflowView = WorkflowLauncher(isLaunched: .constant(true)) {
            thenProceed(with: FR1.self).persistence {
                defer { expectation.fulfill() }
                return .persistWhenSkipped
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectation, expectViewLoaded], timeout: TestConstant.timeout)
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
        let workflowView = WorkflowLauncher(isLaunched: .constant(true)) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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
        let workflowView = WorkflowLauncher(isLaunched: .constant(true)) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }.persistence(.persistWhenSkipped)
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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
        let workflowView = WorkflowLauncher(isLaunched: .constant(true)) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }.persistence { .persistWhenSkipped }
        }

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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
        let workflowView = WorkflowLauncher(isLaunched: .constant(true)) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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
        let workflowView = WorkflowLauncher(isLaunched: .constant(true)) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }.persistence(.persistWhenSkipped)
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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
        let workflowView = WorkflowLauncher(isLaunched: .constant(true)) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }.persistence { .persistWhenSkipped }
        }

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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
        let workflowView = WorkflowLauncher(isLaunched: .constant(true)) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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
        let workflowView = WorkflowLauncher(isLaunched: .constant(true)) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }.persistence(.persistWhenSkipped)
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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
        let workflowView = WorkflowLauncher(isLaunched: .constant(true)) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }.persistence { .persistWhenSkipped }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    // MARK: Input Type == AnyWorkflow.PassedArgs

    func testWhenInputIsAnyWorkflowPassedArgs_FlowPersistenceCanBeSetWithAutoclosure() {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self).persistence(.persistWhenSkipped)
        }

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testWhenInputIsAnyWorkflowPassedArgs_PresentationTypeCanBeSetWithAutoclosure() {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self).presentationType(.navigationLink)
        }

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().presentationType, .navigationLink)
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testWhenInputIsAnyWorkflowPassedArgs_FlowPersistenceCanBeSetWithClosure() {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: AnyWorkflow.PassedArgs) { }
        }
        let expectedArgs = UUID().uuidString

        let expectation = self.expectation(description: "FlowPersistence closure called")
        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self).persistence {
                XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
                defer { expectation.fulfill() }
                return .persistWhenSkipped
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded, expectation], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }.persistence(.persistWhenSkipped)
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }.persistence {
                XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
                return .persistWhenSkipped
            }
        }

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }.persistence(.persistWhenSkipped)
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }.persistence {
                XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
                return .persistWhenSkipped
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }.persistence(.persistWhenSkipped)
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }.persistence {
                XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
                return .persistWhenSkipped
            }
        }

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    // MARK: Input Type == Concrete Type
    func testWhenInputIsConcreteType_FlowPersistenceCanBeSetWithAutoclosure() {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self).persistence(.persistWhenSkipped)
        }

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testWhenInputIsConcreteType_PresentationTypeCanBeSetWithAutoclosure() {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self).presentationType(.navigationLink)
        }

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().presentationType, .navigationLink)
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testWhenInputIsConcreteType_FlowPersistenceCanBeSetWithClosure() {
        struct FR1: FlowRepresentable, View, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
            init(with args: String) { }
        }
        let expectedArgs = UUID().uuidString

        let expectation = self.expectation(description: "FlowPersistence closure called")
        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self).persistence {
                XCTAssertEqual($0, expectedArgs)
                defer { expectation.fulfill() }
                return .persistWhenSkipped
            }
        }

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
        }
        wait(for: [expectViewLoaded, expectation], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }.persistence(.persistWhenSkipped)
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }.persistence {
                XCTAssertEqual($0, expectedArgs)
                return .persistWhenSkipped
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }.persistence(.persistWhenSkipped)
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }.persistence {
                XCTAssertEqual($0, expectedArgs)
                return .persistWhenSkipped
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }.persistence(.persistWhenSkipped)
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }.persistence {
                XCTAssertEqual($0, expectedArgs)
                return .persistWhenSkipped
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in

            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(""))
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }.persistence(.persistWhenSkipped)
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(""))
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR1.self) {
                thenProceed(with: FR2.self)
            }.persistence {
                XCTAssertEqual($0, expectedArgs)
                return .persistWhenSkipped
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(""))
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR2.self))
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self).persistence(.persistWhenSkipped)
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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
        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self).persistence {
                    defer { expectation.fulfill() }
                    return .persistWhenSkipped
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            }
        }
        wait(for: [expectViewLoaded, expectation], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self).persistence(.persistWhenSkipped)
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                    XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self).persistence { .persistWhenSkipped }
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                    XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self).persistence(.persistWhenSkipped)
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                    XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self).persistence { _ in .persistWhenSkipped }
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                    XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self).persistence(.persistWhenSkipped)
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                    XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self).persistence {
                        XCTAssertEqual($0, 1)
                        return .persistWhenSkipped
                    }
                }
            }
        }

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                    XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self).persistence(.persistWhenSkipped)
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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
        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self).persistence {
                    XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
                    defer { expectation.fulfill() }
                    return .persistWhenSkipped
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            }
        }
        wait(for: [expectViewLoaded, expectation], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self).persistence(.persistWhenSkipped)
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                    XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }.persistence {
                    XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
                    return .persistWhenSkipped
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
                try view.actualView().inspect { view in
                    XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
                    try view.actualView().inspectWrapped { view in
                        XCTAssertNoThrow(try view.find(FR2.self))
                    }
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self).persistence(.persistWhenSkipped)
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                    XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self).persistence {
                        XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedArgs)
                        return .persistWhenSkipped
                    }
                }
            }
        }

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                    XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self).persistence(.persistWhenSkipped)
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                    XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self).persistence {
                        XCTAssertEqual($0, 1)
                        return .persistWhenSkipped
                    }
                }
            }
        }

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                    XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self).persistence(.persistWhenSkipped)
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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
        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self).persistence {
                    XCTAssertEqual($0, expectedArgs)
                    defer { expectation.fulfill() }
                    return .persistWhenSkipped
                }
            }
        }

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertEqual(try view.find(FR1.self).actualView().persistence, .persistWhenSkipped)
            }
        }
        wait(for: [expectViewLoaded, expectation], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self).persistence(.persistWhenSkipped)
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                    XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self).persistence { .persistWhenSkipped }
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                    XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self).persistence(.persistWhenSkipped)
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                    XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self).persistence { _ in .persistWhenSkipped }
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow())
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                    XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self).persistence(.persistWhenSkipped)
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                    XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self).persistence {
                        XCTAssertEqual($0, 1)
                        return .persistWhenSkipped
                    }
                }
            }
        }

        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(1))
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                    XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self)
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(""))
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self).persistence(.persistWhenSkipped)
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(""))
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                    XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self).persistence { _ in .persistWhenSkipped }
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(""))
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                    XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self).persistence(.persistWhenSkipped)
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(expectedArgs))
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                    XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testProceedingTwiceWhenInputIsConcreteTypeWithClosureFlowPersistence_WorkflowCanProceedToNeverItem() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs) {
            thenProceed(with: FR0.self) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self).persistence(.persistWhenSkipped)
                }
            }
        }
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { view in
            XCTAssertNoThrow(try view.find(FR0.self).actualView().proceedInWorkflow())
            try view.actualView().inspectWrapped { view in
                XCTAssertNoThrow(try view.find(FR1.self).actualView().proceedInWorkflow(expectedArgs))
                try view.actualView().inspectWrapped { view in
                    XCTAssertNoThrow(try view.find(FR2.self))
                    XCTAssertEqual(try view.find(FR2.self).actualView().persistence, .persistWhenSkipped)
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }
}
