//
//  WorkflowListener.swift
//  WorkflowExampleTests
//
//  Created by Tyler Thompson on 10/5/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import Workflow

class WorkflowListener {
    var workflow: AnyWorkflow?
    var launchStyle: LaunchStyle?
    var args: Any?
    var launchedFrom: AnyFlowRepresentable?
    var onFinish: ((AnyWorkflow.PassedArgs) -> Void)?
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(workflowLaunched(notification:)), name: .workflowLaunched, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func workflowLaunched(notification: Notification) {
        let dict = notification.object as? [String: Any?]
        workflow = dict?["workflow"] as? AnyWorkflow
        launchStyle = dict?["style"] as? LaunchStyle
        onFinish = dict?["onFinish"] as? ((AnyWorkflow.PassedArgs) -> Void)
        launchedFrom = dict?["launchFrom"] as? AnyFlowRepresentable
        args = dict?["args"] as Any?
    }
}

func XCTAssertWorkflowLaunched(listener: WorkflowListener, workflow: AnyWorkflow, passedArgs: [AnyWorkflow.PassedArgs]) {
    XCTAssertNotNil(listener.workflow, "No workflow found")
    guard let listenerWorkflow = listener.workflow,
          listenerWorkflow.count == workflow.count else {
        XCTFail("workflow does not contain correct representables")
        return
    }

    for node in listenerWorkflow {
        let position = node.position
        guard passedArgs.indices.contains(position) else {
            XCTFail("Could not determine correct passedArgs to use, please make sure you have PassedArgs for every FlowRepresentable in your expected Workflow")
            return
        }
        let actual = type(of: node.value.flowRepresentableFactory(passedArgs[position]).underlyingInstance)
        guard let workflowNode = workflow.first?.traverse(node.position) else {
            XCTFail("expected workflow not as long as actual workflow")
            return
        }
        let expected = type(of: workflowNode.value.flowRepresentableFactory(passedArgs[position]).underlyingInstance)
        XCTAssert(actual == expected, "Expected type: \(expected), but got: \(actual)")
    }
}
