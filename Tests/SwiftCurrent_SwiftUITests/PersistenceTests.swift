//
//  PersistenceTests.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Tyler Thompson on 7/12/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import SwiftUI
import ViewInspector

import SwiftCurrent
@testable import SwiftCurrent_SwiftUI // testable sadly needed for inspection.inspect to work

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class PersistenceTests: XCTestCase, View {
    override func tearDownWithError() throws {
        removeQueuedExpectations()
    }

    // MARK: RemovedAfterProceedingTests
    func testRemovedAfterProceeding_OnFirstItemInAWorkflow() throws {
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
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self) {
                            thenProceed(with: FR4.self)
                        }
                    }
                }
                .persistence(.removedAfterProceeding)
            }
        ).inspection.inspect { viewUnderTest in
            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
            try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
                XCTAssertThrowsError(try viewUnderTest.find(FR2.self).actualView().backUpInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
                try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
                    XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().proceedInWorkflow())
                    try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
                        XCTAssertNoThrow(try viewUnderTest.find(FR4.self).actualView().proceedInWorkflow())
                    }
                }
            }
        }

        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self) {
                            thenProceed(with: FR4.self)
                        }
                    }
                    .persistence(.removedAfterProceeding)
                }
            }
        ).inspection.inspect { fr1 in
            XCTAssertNoThrow(try fr1.find(FR1.self).actualView().proceedInWorkflow())
            try fr1.actualView().inspectWrapped { fr2 in
                XCTAssertNoThrow(try fr2.find(FR2.self).actualView().proceedInWorkflow())
                try fr2.actualView().inspectWrapped { fr3 in
                    XCTAssertNoThrow(try fr3.find(FR3.self).actualView().backUpInWorkflow())
                    try fr1.actualView().inspect { fr1 in
                        XCTAssertNoThrow(try fr1.find(FR1.self).actualView().proceedInWorkflow())
                        try fr1.actualView().inspectWrapped { fr2 in
                            XCTAssertNoThrow(try fr2.find(FR2.self).actualView().proceedInWorkflow())
                            try fr2.actualView().inspectWrapped { fr3 in
                                XCTAssertNoThrow(try fr3.find(FR3.self).actualView().proceedInWorkflow())
                                try fr3.actualView().inspectWrapped { fr4 in
                                    XCTAssertNoThrow(try fr4.find(FR4.self).actualView().proceedInWorkflow())
                                }
                            }
                        }
                    }
                }
            }
        }

        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self) {
                            thenProceed(with: FR4.self).persistence(.removedAfterProceeding)
                        }
                    }
                }
            }
            .onFinish { _ in expectOnFinish.fulfill() }
        ).inspection.inspect { viewUnderTest in
            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
            try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
                try viewUnderTest.actualView().inspectWrapped { fr3 in
                    XCTAssertNoThrow(try fr3.find(FR3.self).actualView().proceedInWorkflow())
                    try fr3.actualView().inspectWrapped { fr4 in
                        XCTAssertNoThrow(try fr4.find(FR4.self).actualView().proceedInWorkflow())
                        XCTAssertThrowsError(try fr4.find(FR4.self))
                        try fr3.actualView().inspect { fr3 in
                            XCTAssertNoThrow(try fr3.find(FR3.self))
                        }
                    }
                }
            }
        }

        wait(for: [expectViewLoaded, expectOnFinish], timeout: TestConstant.timeout)
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
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self) {
                            thenProceed(with: FR4.self)
                        }
                        .persistence(.removedAfterProceeding)
                    }
                    .persistence(.removedAfterProceeding)
                }
            }
        ).inspection.inspect { fr1 in
            XCTAssertNoThrow(try fr1.find(FR1.self).actualView().proceedInWorkflow())
            try fr1.actualView().inspectWrapped { fr2 in
                XCTAssertNoThrow(try fr2.find(FR2.self).actualView().proceedInWorkflow())
                try fr2.actualView().inspectWrapped { fr3 in
                    XCTAssertNoThrow(try fr3.find(FR3.self).actualView().proceedInWorkflow())
                    try fr3.actualView().inspectWrapped { fr4 in
                        XCTAssertNoThrow(try fr4.find(FR4.self).actualView().backUpInWorkflow())
                        try fr1.actualView().inspect { fr1 in
                            XCTAssertNoThrow(try fr1.find(FR1.self).actualView().proceedInWorkflow())
                            try fr1.actualView().inspectWrapped { fr2 in
                                XCTAssertNoThrow(try fr2.find(FR2.self).actualView().proceedInWorkflow())
                                try fr2.actualView().inspectWrapped { fr3 in
                                    XCTAssertNoThrow(try fr3.find(FR3.self).actualView().proceedInWorkflow())
                                    try fr3.actualView().inspectWrapped { fr4 in
                                        XCTAssertNoThrow(try fr4.find(FR4.self).actualView().proceedInWorkflow())
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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
        let binding = Binding(wrappedValue: true)
        let expectOnFinish = expectation(description: "OnFinish called")
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: binding) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self) {
                            thenProceed(with: FR4.self).persistence(.removedAfterProceeding)
                        }
                        .persistence(.removedAfterProceeding)
                    }
                    .persistence(.removedAfterProceeding)
                }
                .persistence(.removedAfterProceeding)
            }
            .onFinish { _ in expectOnFinish.fulfill() })
            .inspection.inspect { fr1 in
                XCTAssertNoThrow(try fr1.find(FR1.self).actualView().proceedInWorkflow())
                try fr1.actualView().inspectWrapped { fr2 in
                    XCTAssertNoThrow(try fr2.find(FR2.self).actualView().proceedInWorkflow())
                    try fr2.actualView().inspectWrapped { fr3 in
                        XCTAssertNoThrow(try fr3.find(FR3.self).actualView().proceedInWorkflow())
                        try fr3.actualView().inspectWrapped { fr4 in
                            XCTAssertThrowsError(try fr4.find(FR4.self).actualView().backUpInWorkflow())
                            XCTAssertNoThrow(try fr4.find(FR4.self).actualView().proceedInWorkflow())
                            XCTAssertThrowsError(try fr4.find(FR4.self))
                            try fr3.actualView().inspect { fr3 in
                                XCTAssertThrowsError(try fr3.find(FR3.self))
                                try fr2.actualView().inspect { fr2 in
                                    XCTAssertThrowsError(try fr2.find(FR2.self))
                                    try fr1.actualView().inspect { fr1 in
                                        XCTAssertThrowsError(try fr1.find(FR1.self))
                                        XCTAssertFalse(binding.wrappedValue, "Binding should be flipped to false")
                                    }
                                }
                            }
                        }
                    }
                }
            }

        wait(for: [expectOnFinish, expectViewLoaded], timeout: TestConstant.timeout)
    }

    // MARK: Closure API Tests

    func testPersistenceWorks_WhenDefinedFromAClosure() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            init(with args: String) { }
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
        let binding = Binding(wrappedValue: true)
        let expectOnFinish = expectation(description: "OnFinish called")
        let expectedStart = UUID().uuidString
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: binding, startingArgs: expectedStart) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self) {
                            thenProceed(with: FR4.self).persistence(.removedAfterProceeding)
                        }
                        .persistence(.removedAfterProceeding)
                    }
                    .persistence(.removedAfterProceeding)
                }
                .persistence {
                    XCTAssertEqual($0, expectedStart)
                    return .removedAfterProceeding
                }
            }
            .onFinish { _ in expectOnFinish.fulfill() })
            .inspection.inspect { fr1 in
                XCTAssertNoThrow(try fr1.find(FR1.self).actualView().proceedInWorkflow())
                try fr1.actualView().inspectWrapped { fr2 in
                    XCTAssertNoThrow(try fr2.find(FR2.self).actualView().proceedInWorkflow())
                    try fr2.actualView().inspectWrapped { fr3 in
                        XCTAssertNoThrow(try fr3.find(FR3.self).actualView().proceedInWorkflow())
                        try fr3.actualView().inspectWrapped { fr4 in
                            XCTAssertThrowsError(try fr4.find(FR4.self).actualView().backUpInWorkflow())
                            XCTAssertNoThrow(try fr4.find(FR4.self).actualView().proceedInWorkflow())
                            XCTAssertThrowsError(try fr4.find(FR4.self))
                            try fr3.actualView().inspect { fr3 in
                                XCTAssertThrowsError(try fr3.find(FR3.self))
                                try fr2.actualView().inspect { fr2 in
                                    XCTAssertThrowsError(try fr2.find(FR2.self))
                                    try fr1.actualView().inspect { fr1 in
                                        XCTAssertThrowsError(try fr1.find(FR1.self))
                                        XCTAssertFalse(binding.wrappedValue, "Binding should be flipped to false")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        wait(for: [expectOnFinish, expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testPersistenceWorks_WhenDefinedFromAClosure_AndItemHasInputOfPassedArgs() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            init(with args: AnyWorkflow.PassedArgs) { }
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
        let binding = Binding(wrappedValue: true)
        let expectOnFinish = expectation(description: "OnFinish called")
        let expectedStart = AnyWorkflow.PassedArgs.args(UUID().uuidString)
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: binding, startingArgs: expectedStart) {
                thenProceed(with: FR1.self) {

                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self) {
                            thenProceed(with: FR4.self).persistence(.removedAfterProceeding)
                        }
                        .persistence(.removedAfterProceeding)
                    }
                    .persistence(.removedAfterProceeding)
                }
                .persistence {
                    XCTAssertNotNil(expectedStart.extractArgs(defaultValue: 1) as? String)
                    XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedStart.extractArgs(defaultValue: 1) as? String)
                    return .removedAfterProceeding
                }
            }
            .onFinish { _ in expectOnFinish.fulfill() })
            .inspection.inspect { fr1 in
                XCTAssertNoThrow(try fr1.find(FR1.self).actualView().proceedInWorkflow())
                try fr1.actualView().inspectWrapped { fr2 in
                    XCTAssertNoThrow(try fr2.find(FR2.self).actualView().proceedInWorkflow())
                    try fr2.actualView().inspectWrapped { fr3 in
                        XCTAssertNoThrow(try fr3.find(FR3.self).actualView().proceedInWorkflow())
                        try fr3.actualView().inspectWrapped { fr4 in
                            XCTAssertThrowsError(try fr4.find(FR4.self).actualView().backUpInWorkflow())
                            XCTAssertNoThrow(try fr4.find(FR4.self).actualView().proceedInWorkflow())
                            XCTAssertThrowsError(try fr4.find(FR4.self))
                            try fr3.actualView().inspect { fr3 in
                                XCTAssertThrowsError(try fr3.find(FR3.self))
                                try fr2.actualView().inspect { fr2 in
                                    XCTAssertThrowsError(try fr2.find(FR2.self))
                                    try fr1.actualView().inspect { fr1 in
                                        XCTAssertThrowsError(try fr1.find(FR1.self))
                                        XCTAssertFalse(binding.wrappedValue, "Binding should be flipped to false")
                                    }
                                }
                            }
                        }
                    }
                }
            }

        wait(for: [expectOnFinish, expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testPersistenceWorks_WhenDefinedFromAClosure_AndItemHasInputOfNever() throws {
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
        let binding = Binding(wrappedValue: true)
        let expectOnFinish = expectation(description: "OnFinish called")
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: binding) {
                thenProceed(with: FR1.self) {

                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self) {
                            thenProceed(with: FR4.self).persistence(.removedAfterProceeding)
                        }
                        .persistence(.removedAfterProceeding)
                    }
                    .persistence(.removedAfterProceeding)
                }
                .persistence { .removedAfterProceeding }
            }
            .onFinish { _ in expectOnFinish.fulfill() })
            .inspection.inspect { fr1 in
                XCTAssertNoThrow(try fr1.find(FR1.self).actualView().proceedInWorkflow())
                try fr1.actualView().inspectWrapped { fr2 in
                    XCTAssertNoThrow(try fr2.find(FR2.self).actualView().proceedInWorkflow())
                    try fr2.actualView().inspectWrapped { fr3 in
                        XCTAssertNoThrow(try fr3.find(FR3.self).actualView().proceedInWorkflow())
                        try fr3.actualView().inspectWrapped { fr4 in
                            XCTAssertThrowsError(try fr4.find(FR4.self).actualView().backUpInWorkflow())
                            XCTAssertNoThrow(try fr4.find(FR4.self).actualView().proceedInWorkflow())
                            XCTAssertThrowsError(try fr4.find(FR4.self))
                            try fr3.actualView().inspect { fr3 in
                                XCTAssertThrowsError(try fr3.find(FR3.self))
                                try fr2.actualView().inspect { fr2 in
                                    XCTAssertThrowsError(try fr2.find(FR2.self))
                                    try fr1.actualView().inspect { fr1 in
                                        XCTAssertThrowsError(try fr1.find(FR1.self))
                                        XCTAssertFalse(binding.wrappedValue, "Binding should be flipped to false")
                                    }
                                }
                            }
                        }
                    }
                }
            }

        wait(for: [expectOnFinish, expectViewLoaded], timeout: TestConstant.timeout)
    }

    // MARK: PersistWhenSkippedTests
    func testPersistWhenSkipped_OnFirstItemInAWorkflow() throws {
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
        struct FR4: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR4 type") }
        }
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self) {
                            thenProceed(with: FR4.self)
                        }
                    }
                }
                .persistence(.persistWhenSkipped)
            }
        ).inspection.inspect { fr1 in
            try fr1.actualView().inspectWrapped { fr2 in
                XCTAssertNoThrow(try fr2.find(FR2.self).actualView().backUpInWorkflow())
                try fr1.actualView().inspect { viewUnderTest in
                    XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
                    try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
                        XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
                        try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
                            XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().proceedInWorkflow())
                            try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
                                XCTAssertNoThrow(try viewUnderTest.find(FR4.self).actualView().proceedInWorkflow())
                            }
                        }
                    }
                }
            }
        }

        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testPersistWhenSkipped_OnMiddleItemInAWorkflow() throws {
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
        struct FR4: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR4 type") }
        }
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self) {
                            thenProceed(with: FR4.self)
                        }
                    }
                    .persistence(.persistWhenSkipped)
                }
            }
        ).inspection.inspect { fr1 in
            XCTAssertNoThrow(try fr1.find(FR1.self).actualView().proceedInWorkflow())
            try fr1.actualView().inspectWrapped { fr2 in
                XCTAssertThrowsError(try fr2.find(FR2.self))
                try fr2.actualView().inspectWrapped { fr3 in
                    XCTAssertNoThrow(try fr3.find(FR3.self).actualView().backUpInWorkflow())
                    try fr2.actualView().inspect { fr2 in
                        XCTAssertNoThrow(try fr2.find(FR2.self).actualView().proceedInWorkflow())
                        try fr2.actualView().inspectWrapped { fr3 in
                            XCTAssertNoThrow(try fr3.find(FR3.self).actualView().proceedInWorkflow())
                            try fr3.actualView().inspectWrapped { fr4 in
                                XCTAssertNoThrow(try fr4.find(FR4.self).actualView().proceedInWorkflow())
                            }
                        }
                    }
                }
            }
        }

        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testPersistWhenSkipped_OnLastItemInAWorkflow() throws {
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
            func shouldLoad() -> Bool { false }
        }
        let expectOnFinish = expectation(description: "OnFinish called")
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self) {
                            thenProceed(with: FR4.self).persistence(.persistWhenSkipped)
                        }
                    }
                }
            }
            .onFinish { _ in expectOnFinish.fulfill() })
            .inspection.inspect { viewUnderTest in
                XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
                try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
                    XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
                    try viewUnderTest.actualView().inspectWrapped { viewUnderTest in
                        XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().proceedInWorkflow())
                    }
                }
            }

        wait(for: [expectViewLoaded, expectOnFinish], timeout: TestConstant.timeout)
    }

    func testPersistWhenSkipped_OnMultipleItemsInAWorkflow() throws {
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
            var body: some View { Text("FR4 type") }
        }
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self) {
                            thenProceed(with: FR4.self)
                        }
                        .persistence(.persistWhenSkipped)
                    }
                    .persistence(.persistWhenSkipped)
                }
            }
        ).inspection.inspect { fr1 in
            XCTAssertNoThrow(try fr1.find(FR1.self).actualView().proceedInWorkflow())
            try fr1.actualView().inspectWrapped { fr2 in
                XCTAssertThrowsError(try fr2.find(FR2.self))
                try fr2.actualView().inspectWrapped { fr3 in
                    XCTAssertThrowsError(try fr3.find(FR3.self))
                    try fr3.actualView().inspectWrapped { fr4 in
                        XCTAssertNoThrow(try fr4.find(FR4.self).actualView().backUpInWorkflow())
                        try fr3.actualView().inspect { fr3 in
                            XCTAssertNoThrow(try fr3.find(FR3.self).actualView().backUpInWorkflow())
                            try fr2.actualView().inspect { fr2 in
                                XCTAssertNoThrow(try fr2.find(FR2.self).actualView().proceedInWorkflow())
                                try fr2.actualView().inspectWrapped { fr3 in
                                    XCTAssertThrowsError(try fr3.find(FR3.self))
                                    try fr3.actualView().inspectWrapped { fr4 in
                                        XCTAssertNoThrow(try fr4.find(FR4.self).actualView().proceedInWorkflow())
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testPersistWhenSkipped_OnAllItemsInAWorkflow() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
            func shouldLoad() -> Bool { false }
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
            var body: some View { Text("FR4 type") }
            func shouldLoad() -> Bool { false }
        }
        let expectOnFinish = expectation(description: "OnFinish called")
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: FR1.self) {
                    thenProceed(with: FR2.self) {
                        thenProceed(with: FR3.self) {
                            thenProceed(with: FR4.self).persistence(.persistWhenSkipped)
                        }
                        .persistence(.persistWhenSkipped)
                    }
                    .persistence(.persistWhenSkipped)
                }
                .persistence(.persistWhenSkipped)
            }
            .onFinish { _ in expectOnFinish.fulfill() })
            .inspection.inspect { fr1 in
                try fr1.actualView().inspectWrapped { fr2 in
                    XCTAssertThrowsError(try fr2.find(FR2.self))
                    try fr2.actualView().inspectWrapped { fr3 in
                        XCTAssertThrowsError(try fr3.find(FR3.self))
                        try fr3.actualView().inspectWrapped { fr4 in
                            XCTAssertNoThrow(try fr4.find(FR4.self))
                        }
                    }
                }
            }
        wait(for: [expectOnFinish, expectViewLoaded], timeout: TestConstant.timeout)
    }
}
