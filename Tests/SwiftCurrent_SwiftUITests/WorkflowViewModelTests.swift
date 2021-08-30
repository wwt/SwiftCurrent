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

import SwiftCurrent_Testing
@testable import SwiftCurrent
@testable import SwiftCurrent_SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class WorkflowViewModelTests: XCTestCase, View {
    override func tearDownWithError() throws {
        removeQueuedExpectations()
    }

    func testAnyWorkflowElementModelThrowsFatalError_WhenExtractCalledOnSomethingOtherThan_AnyFlowRepresentableView() throws {
        try XCTAssertThrowsFatalError {
            _ = AnyWorkflow.Element.createForTests(FR.self).extractErasedView()
        }
    }

    func testAnyWorkflowElementReturnsNil_WhenExtractCalledOnNilValue() throws {
        let element = AnyWorkflow.Element.createForTests(FR.self)
        element.value.instance = nil
        XCTAssertNil(element.extractErasedView())
    }

    func testWorkflowViewModelSetsBodyToNilWhenAbandoning() {
        let isLaunched = Binding(wrappedValue: true)
        let model = WorkflowViewModel(isLaunched: isLaunched, launchArgs: .none)
        let typedWorkflow = Workflow(FR.self)
        model.body = typedWorkflow.first!
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
