//
//  PersistenceTests.swift
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class PersistenceTests: XCTestCase {
    func testRemovedAfterProceeding_OnFirstItemInAWorkflow() throws {
        // NOTE: Workflows in the past had issues with 4+ items, so this is to cover our bases. SwiftUI also has a nasty habit of behaving a little differently as number of views increase.
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
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowView(isPresented: .constant(true))
                .thenProceed(with: WorkflowItem(FR1.self).persistence(.removedAfterProceeding))
                .thenProceed(with: WorkflowItem(FR2.self))
                .thenProceed(with: WorkflowItem(FR3.self))
                .thenProceed(with: WorkflowItem(FR4.self)))
            .inspection.inspect { viewUnderTest in
                XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
                XCTAssertThrowsError(try viewUnderTest.find(FR2.self).actualView().backUpInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR4.self).actualView().proceedInWorkflow())
            }

        wait(for: [expectViewLoaded], timeout: 0.3)
    }

    func testRemovedAfterProceeding_OnMiddleItemInAWorkflow() throws {
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
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowView(isPresented: .constant(true))
                .thenProceed(with: WorkflowItem(FR1.self))
                .thenProceed(with: WorkflowItem(FR2.self).persistence(.removedAfterProceeding))
                .thenProceed(with: WorkflowItem(FR3.self))
                .thenProceed(with: WorkflowItem(FR4.self)))
            .inspection.inspect { viewUnderTest in
                XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().backUpInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR4.self).actualView().proceedInWorkflow())
            }

        wait(for: [expectViewLoaded], timeout: 0.3)
    }

    func testRemovedAfterProceeding_OnLastItemInAWorkflow() throws {
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
        let expectOnFinish = expectation(description: "OnFinish called")
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowView(isPresented: .constant(true))
                .thenProceed(with: WorkflowItem(FR1.self))
                .thenProceed(with: WorkflowItem(FR2.self))
                .thenProceed(with: WorkflowItem(FR3.self))
                .thenProceed(with: WorkflowItem(FR4.self).persistence(.removedAfterProceeding))
                .onFinish { _ in expectOnFinish.fulfill() })
            .inspection.inspect { viewUnderTest in
                XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR4.self).actualView().proceedInWorkflow())
                XCTAssertThrowsError(try viewUnderTest.find(FR4.self))
                XCTAssertNoThrow(try viewUnderTest.find(FR3.self))
            }

        wait(for: [expectViewLoaded, expectOnFinish], timeout: 0.3)
    }

    func testRemovedAfterProceeding_OnMultipleItemsInAWorkflow() throws {
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
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowView(isPresented: .constant(true))
                .thenProceed(with: WorkflowItem(FR1.self))
                .thenProceed(with: WorkflowItem(FR2.self).persistence(.removedAfterProceeding))
                .thenProceed(with: WorkflowItem(FR3.self).persistence(.removedAfterProceeding))
                .thenProceed(with: WorkflowItem(FR4.self)))
            .inspection.inspect { viewUnderTest in
                // Is there a brand new test that has to be written that backs up after the first thing, then goes forward, then backs up again?
                // Does not make sense to combine with this one, this test is valuable on its own.
                XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR4.self).actualView().backUpInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR4.self).actualView().proceedInWorkflow())
            }

        wait(for: [expectViewLoaded], timeout: 0.3)
    }

    func testRemovedAfterProceeding_OnAllItemsInAWorkflow() throws {
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
        let expectOnFinish = expectation(description: "OnFinish called")
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowView(isPresented: .constant(true))
                .thenProceed(with: WorkflowItem(FR1.self).persistence(.removedAfterProceeding))
                .thenProceed(with: WorkflowItem(FR2.self).persistence(.removedAfterProceeding))
                .thenProceed(with: WorkflowItem(FR3.self).persistence(.removedAfterProceeding))
                .thenProceed(with: WorkflowItem(FR4.self).persistence(.removedAfterProceeding))
                .onFinish { _ in expectOnFinish.fulfill() })
            .inspection.inspect { viewUnderTest in
                XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().proceedInWorkflow())
                XCTAssertThrowsError(try viewUnderTest.find(FR4.self).actualView().backUpInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR4.self).actualView().proceedInWorkflow())
                XCTAssertThrowsError(try viewUnderTest.find(FR4.self))
                XCTAssertThrowsError(try viewUnderTest.find(FR3.self))
                XCTAssertThrowsError(try viewUnderTest.find(FR2.self))
                XCTAssertThrowsError(try viewUnderTest.find(FR1.self))
            }

        wait(for: [expectOnFinish, expectViewLoaded], timeout: 0.3)
    }
}
