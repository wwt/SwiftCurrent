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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class SwiftCurrent_SwiftUIConsumerTests: XCTestCase {
    func testWorkflowCanBeFollowed() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }
        let expectOnFinish = expectation(description: "OnFinish called")
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowView(isPresented: .constant(true))
                .thenProceed(with: WorkflowItem(FR1.self))
                .thenProceed(with: WorkflowItem(FR2.self))
                .onFinish { _ in
            expectOnFinish.fulfill()
        }).inspection.inspect { viewUnderTest in
            XCTAssertEqual(try viewUnderTest.vStack().anyView(0).view(FR1.self).text().string(), "FR1 type")
            XCTAssertNoThrow(try viewUnderTest.vStack().anyView(0).view(FR1.self).actualView().proceedInWorkflow())
            XCTAssertEqual(try viewUnderTest.vStack().anyView(0).view(FR2.self).text().string(), "FR2 type")
            XCTAssertNoThrow(try viewUnderTest.vStack().anyView(0).view(FR2.self).actualView().proceedInWorkflow())
        }

        wait(for: [expectOnFinish, expectViewLoaded], timeout: 0.3)
    }

    func testWorkflowCanHaveMultipleOnFinishClosures() throws {
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
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowView(isPresented: .constant(true))
                .thenProceed(with: WorkflowItem(FR1.self))
                .onFinish { _ in
            expectOnFinish1.fulfill()
        }.onFinish { _ in
            expectOnFinish2.fulfill()
        }).inspection.inspect { viewUnderTest in
            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
        }

        wait(for: [expectOnFinish1, expectOnFinish2, expectViewLoaded], timeout: 0.3)
    }

    func testLargeWorkflowCanBeFollowed() throws {
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
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowView(isPresented: .constant(true))
                .thenProceed(with: WorkflowItem(FR1.self))
                .thenProceed(with: WorkflowItem(FR2.self))
                .thenProceed(with: WorkflowItem(FR3.self))
                .thenProceed(with: WorkflowItem(FR4.self))
                .thenProceed(with: WorkflowItem(FR5.self))
                .thenProceed(with: WorkflowItem(FR6.self))
                .thenProceed(with: WorkflowItem(FR7.self)))
            .inspection.inspect { viewUnderTest in
                XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR4.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR5.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR6.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR7.self).actualView().proceedInWorkflow())
            }

        wait(for: [expectViewLoaded], timeout: 0.3)
    }

    func testMovingBiDirectionallyInAWorkflow() throws {
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
                .thenProceed(with: WorkflowItem(FR2.self))
                .thenProceed(with: WorkflowItem(FR3.self))
                .thenProceed(with: WorkflowItem(FR4.self)))
            .inspection.inspect { viewUnderTest in
                XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().backUpInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().backUpInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR4.self).actualView().proceedInWorkflow())
            }

        wait(for: [expectViewLoaded], timeout: 0.3)
    }

    func testWorkflowSetsBindingBooleanToFalseWhenAbandoned() throws {
        // NOTE: This test is un-vetted. It probably is either correct or close to correct, though.
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        let isPresented = Binding(wrappedValue: true)
        let expectOnAbandon = expectation(description: "OnAbandon called")
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowView(isPresented: isPresented)
                .thenProceed(with: WorkflowItem(FR1.self))
                .onAbandon {
            expectOnAbandon.fulfill()
            XCTAssertFalse(isPresented.wrappedValue)
        }).inspection.inspect { viewUnderTest in
            XCTAssertEqual(try viewUnderTest.find(FR1.self).text().string(), "FR1 type")
            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().workflow?.abandon())
        }

        wait(for: [expectOnAbandon, expectViewLoaded], timeout: 0.3)
    }
}
