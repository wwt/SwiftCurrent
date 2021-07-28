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

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
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
            WorkflowLauncher(isLaunched: .constant(true))
                .thenProceed(with: WorkflowItem(FR1.self))
                .thenProceed(with: WorkflowItem(FR2.self))
                .onFinish { _ in
            expectOnFinish.fulfill()
        }).inspection.inspect { viewUnderTest in
            XCTAssertEqual(try viewUnderTest.find(FR1.self).text().string(), "FR1 type")
            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertEqual(try viewUnderTest.find(FR2.self).text().string(), "FR2 type")
            XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
        }

        wait(for: [expectOnFinish, expectViewLoaded], timeout: TestConstant.timeout)
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
            WorkflowLauncher(isLaunched: .constant(true))
                .thenProceed(with: WorkflowItem(FR1.self))
                .onFinish { _ in
            expectOnFinish1.fulfill()
        }.onFinish { _ in
            expectOnFinish2.fulfill()
        }).inspection.inspect { viewUnderTest in
            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
        }

        wait(for: [expectOnFinish1, expectOnFinish2, expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testOnFinishWorksEvenWhenItIsNotTheLastItem() throws {
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
            WorkflowLauncher(isLaunched: .constant(true))
                .thenProceed(with: WorkflowItem(FR1.self))
                .onFinish { _ in expectOnFinish.fulfill() } // what kind of monster does this?!
                .thenProceed(with: WorkflowItem(FR2.self))).inspection.inspect { viewUnderTest in
            XCTAssertEqual(try viewUnderTest.find(FR1.self).text().string(), "FR1 type")
            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertEqual(try viewUnderTest.find(FR2.self).text().string(), "FR2 type")
            XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
        }

        wait(for: [expectOnFinish, expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testOnFinishWorksEvenWhenItIsTheFirstItem() throws {
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
            WorkflowLauncher(isLaunched: .constant(true))
                .onFinish { _ in expectOnFinish.fulfill() } // what kind of monster does this?!
                .thenProceed(with: WorkflowItem(FR1.self))
                .thenProceed(with: WorkflowItem(FR2.self))).inspection.inspect { viewUnderTest in
            XCTAssertEqual(try viewUnderTest.find(FR1.self).text().string(), "FR1 type")
            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertEqual(try viewUnderTest.find(FR2.self).text().string(), "FR2 type")
            XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
        }

        wait(for: [expectOnFinish, expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testWorkflowPassesArgumentsToTheFirstItem() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            let stringProperty: String
            init(with: String) {
                self.stringProperty = with
            }
            var body: some View { Text("FR1 type") }
        }
        let expected = UUID().uuidString
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expected)
                .thenProceed(with: WorkflowItem(FR1.self))).inspection.inspect { viewUnderTest in
            XCTAssertEqual(try viewUnderTest.find(FR1.self).actualView().stringProperty, expected)
        }

        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testWorkflowPassesArgumentsToTheFirstItem_WhenThatFirstItemTakesInAnyWorkflowPassedArgs() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            let property: AnyWorkflow.PassedArgs
            init(with: AnyWorkflow.PassedArgs) {
                self.property = with
            }
            var body: some View { Text("FR1 type") }
        }
        let expected = UUID().uuidString
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expected)
                .thenProceed(with: WorkflowItem(FR1.self))
                .thenProceed(with: WorkflowItem(FR1.self))).inspection.inspect { viewUnderTest in
            XCTAssertEqual(try viewUnderTest.find(FR1.self).actualView().property.extractArgs(defaultValue: nil) as? String, expected)
        }

        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testWorkflowPassesArgumentsToTheFirstItem_WhenThatFirstItemTakesInAnyWorkflowPassedArgs_AndTheLaunchArgsAreAnyWorkflowPassedArgs() throws {
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
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: AnyWorkflow.PassedArgs.args(expected))
                .thenProceed(with: WorkflowItem(FR1.self))
                .thenProceed(with: WorkflowItem(FR1.self))).inspection.inspect { viewUnderTest in
            XCTAssertEqual(try viewUnderTest.find(FR1.self).actualView().property.extractArgs(defaultValue: nil) as? String, expected)
        }

        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testWorkflowPassesArgumentsToAllItems() throws {
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
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedFR1)
                .thenProceed(with: WorkflowItem(FR1.self))
                .thenProceed(with: WorkflowItem(FR2.self))
                .thenProceed(with: WorkflowItem(FR3.self))
                .onFinish {
            XCTAssertEqual($0.extractArgs(defaultValue: nil) as? String, expectedEnd)
        }).inspection.inspect { viewUnderTest in
            XCTAssertEqual(try viewUnderTest.find(FR1.self).actualView().property, expectedFR1)
            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow(expectedFR2))
            XCTAssertEqual(try viewUnderTest.find(FR2.self).actualView().property, expectedFR2)
            XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow(expectedFR3))
            XCTAssertEqual(try viewUnderTest.find(FR3.self).actualView().property, expectedFR3)
            XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().proceedInWorkflow(expectedEnd))
        }

        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
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
            WorkflowLauncher(isLaunched: .constant(true))
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

        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testWorkflowOnlyShowsOneViewAtATime() throws {
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
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: .constant(true))
                .thenProceed(with: WorkflowItem(FR1.self))
                .thenProceed(with: WorkflowItem(FR2.self))
                .thenProceed(with: WorkflowItem(FR3.self))
                .thenProceed(with: WorkflowItem(FR2.self)))
            .inspection.inspect { viewUnderTest in
                XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().proceedInWorkflow())
                XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
                XCTAssertThrowsError(try viewUnderTest.find(ViewType.Text.self, skipFound: 1))
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
            WorkflowLauncher(isLaunched: .constant(true))
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

        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testWorkflowSetsBindingBooleanToFalseWhenAbandoned() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        let isLaunched = Binding(wrappedValue: true)
        let expectOnAbandon = expectation(description: "OnAbandon called")
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: isLaunched)
                .thenProceed(with: WorkflowItem(FR1.self))
                .onAbandon {
            XCTAssertFalse(isLaunched.wrappedValue)
            expectOnAbandon.fulfill()
        }).inspection.inspect { viewUnderTest in
            XCTAssertEqual(try viewUnderTest.find(FR1.self).text().string(), "FR1 type")
            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().workflow?.abandon())
            XCTAssertThrowsError(try viewUnderTest.find(FR1.self))
        }

        wait(for: [expectOnAbandon, expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testWorkflowCanHaveMultipleOnAbandonCallbacks() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        let isLaunched = Binding(wrappedValue: true)
        let expectOnAbandon1 = expectation(description: "OnAbandon1 called")
        let expectOnAbandon2 = expectation(description: "OnAbandon2 called")
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: isLaunched)
                .thenProceed(with: WorkflowItem(FR1.self))
                .onAbandon {
            XCTAssertFalse(isLaunched.wrappedValue)
            expectOnAbandon1.fulfill()
        }.onAbandon {
            XCTAssertFalse(isLaunched.wrappedValue)
            expectOnAbandon2.fulfill()
        }).inspection.inspect { viewUnderTest in
            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().workflow?.abandon())
            XCTAssertThrowsError(try viewUnderTest.find(FR1.self))
        }

        wait(for: [expectOnAbandon1, expectOnAbandon2, expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testWorkflowCanAbandonEvenIfItIsNotTheLastStatement() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        let isLaunched = Binding(wrappedValue: true)
        let expectOnAbandon = expectation(description: "OnAbandon called")
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: isLaunched)
                .thenProceed(with: WorkflowItem(FR1.self))
                .onAbandon { // Again, MONSTERS do this
                    XCTAssertFalse(isLaunched.wrappedValue)
                    expectOnAbandon.fulfill()
                }
                .thenProceed(with: WorkflowItem(FR1.self))).inspection.inspect { viewUnderTest in
            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().workflow?.abandon())
            XCTAssertThrowsError(try viewUnderTest.find(FR1.self))
        }

        wait(for: [expectOnAbandon, expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testWorkflowLauncherCanAbandonEvenIfItIsTheFirstStatement() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }
        }
        let isLaunched = Binding(wrappedValue: true)
        let expectOnAbandon = expectation(description: "OnAbandon called")
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: isLaunched)
                .onAbandon { // Again, MONSTERS do this
                    XCTAssertFalse(isLaunched.wrappedValue)
                    expectOnAbandon.fulfill()
                }
                .thenProceed(with: WorkflowItem(FR1.self))
                .thenProceed(with: WorkflowItem(FR1.self))).inspection.inspect { viewUnderTest in
            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().workflow?.abandon())
            XCTAssertThrowsError(try viewUnderTest.find(FR1.self))
        }

        wait(for: [expectOnAbandon, expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testWorkflowCanHaveModifiers() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }

            func customModifier() -> Self { self }
        }

        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: .constant(true))
                .thenProceed(with: WorkflowItem(FR1.self)
                                .applyModifiers { $0.customModifier().background(Color.blue) })).inspection.inspect { viewUnderTest in
            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).background())
        }

        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testWorkflowRelaunchesWhenSubsequentlyLaunched() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR1 type") }

            func customModifier() -> Self { self }
        }
        struct FR2: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("FR2 type") }
        }

        let binding = Binding(wrappedValue: true)
        let workflowView = WorkflowLauncher(isLaunched: binding)
            .thenProceed(with: WorkflowItem(FR1.self)
                            .applyModifiers { $0.customModifier().background(Color.blue) })
            .thenProceed(with: WorkflowItem(FR2.self))
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { viewUnderTest in
            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())

            binding.wrappedValue = false
            XCTAssertThrowsError(try viewUnderTest.find(FR1.self))
            XCTAssertThrowsError(try viewUnderTest.find(FR2.self))

            binding.wrappedValue = true
            XCTAssertNoThrow(try viewUnderTest.find(FR2.self).callOnChange(newValue: true))
            XCTAssertNoThrow(try viewUnderTest.find(FR1.self))
            XCTAssertThrowsError(try viewUnderTest.find(FR2.self))
        }

        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testWorkflowRelaunchesWhenAbandoned_WithAConstantOfTrue() throws {
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

        let workflowView = WorkflowLauncher(isLaunched: .constant(true))
            .thenProceed(with: WorkflowItem(FR1.self))
            .thenProceed(with: WorkflowItem(FR2.self))
        let expectViewLoaded = ViewHosting.loadView(workflowView).inspection.inspect { viewUnderTest in
            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().abandon())

            XCTAssertThrowsError(try viewUnderTest.find(FR2.self))
            XCTAssertNoThrow(try viewUnderTest.find(FR1.self))
        }

        wait(for: [expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testWorkflowCanHaveAPassthroughRepresentable() throws {
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
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: expectedArgs)
                .thenProceed(with: WorkflowItem(FR1.self))
                .thenProceed(with: WorkflowItem(FR2.self))
                .onFinish { _ in
            expectOnFinish.fulfill()
        }).inspection.inspect { viewUnderTest in
            XCTAssertEqual(try viewUnderTest.find(FR1.self).text().string(), "FR1 type")
            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow(.args(expectedArgs)))
            XCTAssertEqual(try viewUnderTest.find(FR2.self).text().string(), "FR2 type")
            XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow())
        }

        wait(for: [expectOnFinish, expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testWorkflowCanConvertAnyArgsToCorrectTypeForFirstItem() throws {
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
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: .constant(true), startingArgs: AnyWorkflow.PassedArgs.args(expectedArgs))
                .thenProceed(with: WorkflowItem(FR1.self))
                .onFinish { _ in
            expectOnFinish.fulfill()
        }).inspection.inspect { viewUnderTest in
            XCTAssertEqual(try viewUnderTest.find(FR1.self).text().string(), "FR1 type")
            XCTAssertEqual(try viewUnderTest.find(FR1.self).actualView().data, expectedArgs)
            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
        }

        wait(for: [expectOnFinish, expectViewLoaded], timeout: TestConstant.timeout)
    }

    func testWorkflowCanHaveAPassthroughRepresentableInTheMiddle() throws {
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
        let expectViewLoaded = ViewHosting.loadView(
            WorkflowLauncher(isLaunched: .constant(true))
                .thenProceed(with: WorkflowItem(FR1.self))
                .thenProceed(with: WorkflowItem(FR2.self))
                .thenProceed(with: WorkflowItem(FR3.self))
                .onFinish { _ in
            expectOnFinish.fulfill()
        }).inspection.inspect { viewUnderTest in
            XCTAssertEqual(try viewUnderTest.find(FR1.self).text().string(), "FR1 type")
            XCTAssertNoThrow(try viewUnderTest.find(FR1.self).actualView().proceedInWorkflow())
            XCTAssertEqual(try viewUnderTest.find(FR2.self).text().string(), "FR2 type")
            XCTAssertNoThrow(try viewUnderTest.find(FR2.self).actualView().proceedInWorkflow(.args(expectedArgs)))
            XCTAssertEqual(try viewUnderTest.find(FR3.self).text().string(), "FR3 type, \(expectedArgs)")
            XCTAssertNoThrow(try viewUnderTest.find(FR3.self).actualView().proceedInWorkflow())
        }

        wait(for: [expectOnFinish, expectViewLoaded], timeout: TestConstant.timeout)
    }
}
