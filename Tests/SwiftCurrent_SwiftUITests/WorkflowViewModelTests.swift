//
//  WorkflowViewModelTests.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Tyler Thompson on 7/13/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest

@testable import SwiftCurrent
@testable import SwiftCurrent_SwiftUI

final class WorkflowViewModelTests: XCTestCase {
    func testWorkflowViewModelThrowsFatalError_WhenLaunchedWithSomethingOtherThan_AnyFlowRepresentableView() {
        let model = WorkflowViewModel()
        XCTAssertThrowsFatalError {
            model.launch(to: .createForTests(FR.self))
        }
    }

    func testWorkflowViewModelThrowsFatalError_WhenProceedingWithSomethingOtherThan_AnyFlowRepresentableView() {
        let model = WorkflowViewModel()
        XCTAssertThrowsFatalError {
            model.proceed(to: .createForTests(FR.self), from: .createForTests(FR.self))
        }
    }

    func testWorkflowViewModelThrowsFatalError_WhenBackingUpWithSomethingOtherThan_AnyFlowRepresentableView() {
        let model = WorkflowViewModel()
        XCTAssertThrowsFatalError {
            model.backUp(from: .createForTests(FR.self), to: .createForTests(FR.self))
        }
    }

    func testWorkflowViewModelThrowsFatalError_WhenCompletingWithSomethingOtherThan_AnyFlowRepresentableView() {
        let model = WorkflowViewModel()
        let typedWorkflow = Workflow(FR.self).thenProceed(with: FR.self, flowPersistence: .removedAfterProceeding)
        let mock = MockOrchestrationResponder()
        let firstLoadedInstance = typedWorkflow.launch(withOrchestrationResponder: mock)
        firstLoadedInstance?.value.instance?.proceedInWorkflowStorage?(.none)
        XCTAssertThrowsFatalError {
            model.complete(AnyWorkflow(typedWorkflow), passedArgs: .none, onFinish: nil)
        }
    }

//    if workflow.lastLoadedItem?.value.metadata.persistence == .removedAfterProceeding {
//        if let lastPresentableItem = workflow.lastPresentableItem {
//            #warning("come back to this")
//            // swiftlint:disable:next force_cast
//            let afrv = lastPresentableItem.value.instance as! AnyFlowRepresentableView
//            afrv.model = self
//        } else {
//            #warning("We are a little worried about animation here")
//            body = AnyView(EmptyView())
//        }
//    }

}

fileprivate struct FR: FlowRepresentable {
    var _workflowPointer: AnyFlowRepresentable?
}

extension FlowRepresentableMetadata {
    static func createForTests<FR: FlowRepresentable>(_: FR.Type) -> FlowRepresentableMetadata {
        .init(FR.self, flowPersistence: { _ in .default })
    }
}

extension AnyWorkflow.Element {
    static func createForTests<FR: FlowRepresentable>(_ :FR.Type) -> AnyWorkflow.Element {
        return .init(with: .init(metadata: .createForTests(FR.self),
                                 instance: AnyFlowRepresentable(FR.self, args: .none)))
    }
}
