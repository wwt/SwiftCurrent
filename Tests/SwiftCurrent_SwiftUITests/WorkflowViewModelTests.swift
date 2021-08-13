//
//  WorkflowViewModelTests.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Tyler Thompson on 7/13/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import ViewInspector
import SwiftUI

@testable import SwiftCurrent
@testable import SwiftCurrent_SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class WorkflowViewModelTests: XCTestCase {
    func testWorkflowViewModelThrowsFatalError_WhenLaunchedWithSomethingOtherThan_AnyFlowRepresentableView() throws {
        let model = WorkflowViewModel(isLaunched: .constant(true), launchArgs: .none)
        try XCTAssertThrowsFatalError {
            model.launch(to: .createForTests(FR.self))
        }
    }

    func testWorkflowViewModelThrowsFatalError_WhenProceedingWithSomethingOtherThan_AnyFlowRepresentableView() throws {
        let model = WorkflowViewModel(isLaunched: .constant(true), launchArgs: .none)
        try XCTAssertThrowsFatalError {
            model.proceed(to: .createForTests(FR.self), from: .createForTests(FR.self))
        }
    }

    func testWorkflowViewModelThrowsFatalError_WhenBackingUpWithSomethingOtherThan_AnyFlowRepresentableView() throws {
        let model = WorkflowViewModel(isLaunched: .constant(true), launchArgs: .none)
        try XCTAssertThrowsFatalError {
            model.backUp(from: .createForTests(FR.self), to: .createForTests(FR.self))
        }
    }

    func testWorkflowViewModelThrowsFatalError_WhenCompletingWithSomethingOtherThan_AnyFlowRepresentableView() throws {
        let model = WorkflowViewModel(isLaunched: .constant(true), launchArgs: .none)
        let typedWorkflow = Workflow(FR.self).thenProceed(with: FR.self, flowPersistence: .removedAfterProceeding)
        let mock = MockOrchestrationResponder()
        let firstLoadedInstance = typedWorkflow.launch(withOrchestrationResponder: mock)
        firstLoadedInstance?.value.instance?.proceedInWorkflowStorage?(.none)
        try XCTAssertThrowsFatalError {
            model.complete(AnyWorkflow(typedWorkflow), passedArgs: .none, onFinish: nil)
        }
    }

    func testWorkflowViewModelSetsBodyToNilWhenAbandoning() {
        let isLaunched = Binding(wrappedValue: true)
        let model = WorkflowViewModel(isLaunched: isLaunched, launchArgs: .none)
        model.body = ""
        let typedWorkflow = Workflow(FR.self)
        model.abandon(AnyWorkflow(typedWorkflow), onFinish: nil)

        XCTAssertNil(model.body)
    }
}

fileprivate struct FR: FlowRepresentable {
    var _workflowPointer: AnyFlowRepresentable?
}

extension FlowRepresentableMetadata {
    fileprivate static func createForTests<FR: FlowRepresentable>(_: FR.Type) -> FlowRepresentableMetadata {
        .init(FR.self, flowPersistence: { _ in .default })
    }
}

extension AnyWorkflow.Element {
    fileprivate static func createForTests<FR: FlowRepresentable>(_ :FR.Type) -> AnyWorkflow.Element {
        return .init(with: .init(metadata: .createForTests(FR.self),
                                 instance: AnyFlowRepresentable(FR.self, args: .none)))
    }
}
