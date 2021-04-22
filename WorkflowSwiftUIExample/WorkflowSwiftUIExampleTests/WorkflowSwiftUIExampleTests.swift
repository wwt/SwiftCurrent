//
//  WorkflowSwiftUIExampleTests.swift
//  WorkflowSwiftUIExampleTests
//
//  Created by thompsty on 11/30/20.
//

import XCTest
import SwiftUI
import Workflow
@testable import WorkflowSwiftUI
import ViewInspector

class WorkflowSwiftUIExampleTests: XCTestCase {
    func testProceedingForwardWithWorkflow_WithDefaultLaunchStyle_AndDefaultPresentation_CallsThroughToOnFinish() throws {
        let expectation = self.expectation(description: "OnFinish called")
        let view = WorkflowView(Workflow(FR1.self)
                                    .thenPresent(FR2.self)
                                    .thenPresent(FR3.self)
                                    .thenPresent(FR4.self)) { _ in expectation.fulfill() }

        let fr1 = try view.workflowModel.view.inspect().anyView().view(FR1.self).actualView()
        fr1.proceedInWorkflow()
        let fr2 = try view.workflowModel.view.inspect().anyView().view(FR2.self).actualView()
        fr2.proceedInWorkflow()
        let fr3 = try view.workflowModel.view.inspect().anyView().view(FR3.self).actualView()
        fr3.proceedInWorkflow()
        let fr4 = try view.workflowModel.view.inspect().anyView().view(FR4.self).actualView()
        fr4.proceedInWorkflow()

        wait(for: [expectation], timeout: 3)
    }
}

extension ModalWrapper: Inspectable {}

extension WorkflowSwiftUIExampleTests {
    struct FR1: View, FlowRepresentable, Inspectable {
        var _workflowPointer: AnyFlowRepresentable?

        static func instance() -> Self { Self() }

        var body: some View {
            Text("\(String(describing: Self.self))")
                .padding()
            Button("Proceed", action: proceedInWorkflow)
        }
    }

    struct FR2: View, FlowRepresentable, Inspectable {
        var _workflowPointer: AnyFlowRepresentable?

        static func instance() -> Self { Self() }

        var body: some View {
            Text("\(String(describing: Self.self))")
                .padding()
            Button("Proceed", action: proceedInWorkflow)
            Button("Back", action: proceedBackwardInWorkflow)
        }
    }

    struct FR3: View, FlowRepresentable, Inspectable {
        var _workflowPointer: AnyFlowRepresentable?

        static func instance() -> Self { Self() }

        var body: some View {
            Text("\(String(describing: Self.self))")
                .padding()
            Button("Proceed", action: proceedInWorkflow)
            Button("Back", action: proceedBackwardInWorkflow)
        }
    }

    struct FR4: View, FlowRepresentable, Inspectable {
        var _workflowPointer: AnyFlowRepresentable?

        static func instance() -> Self { Self() }

        var body: some View {
            Text("\(String(describing: Self.self))")
                .padding()
            Button("Back", action: proceedBackwardInWorkflow)
            Button("Abandon") {
                workflow?.abandon()
            }
        }
    }
}
