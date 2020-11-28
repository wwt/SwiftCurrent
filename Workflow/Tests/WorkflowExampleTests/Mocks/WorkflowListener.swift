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
    var workflow:AnyWorkflow?
    var launchStyle:LaunchStyle?
    var args:Any?
    var launchedFrom:AnyFlowRepresentable?
    var onFinish:((Any?) -> Void)?
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(workflowLaunched(notification:)), name: .workflowLaunched, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func workflowLaunched(notification: Notification) {
        let dict = notification.object as? [String:Any?]
        workflow = dict?["workflow"] as? AnyWorkflow
        launchStyle = dict?["style"] as? LaunchStyle
        onFinish = dict?["onFinish"] as? ((Any?) -> Void)
        launchedFrom = dict?["launchFrom"] as? AnyFlowRepresentable
        args = dict?["args"] as Any?
    }
}

func XCTAssertWorkflowLaunched(listener: WorkflowListener, workflow:AnyWorkflow) {
    XCTAssertNotNil(listener.workflow, "No workflow found")
    guard let listenerWorkflow = listener.workflow,
          listenerWorkflow.count == workflow.count else {
        XCTFail("workflow does not contain correct representables: \(String(describing: listener.workflow?.flowRepresentableTypes) )")
        return
    }

    for node in listenerWorkflow {
        let actual = type(of: node.value.flowRepresentableFactory().underlyingInstance)
        guard let workflowNode = workflow.first?.traverse(node.position) else {
            XCTFail("expected workflow not as long as actual workflow")
            return
        }
        let expected = type(of: workflowNode.value.flowRepresentableFactory().underlyingInstance)
        XCTAssert(actual == expected, "Expected type: \(expected), but got: \(actual)")
    }
}

extension AnyWorkflow {
    var flowRepresentableTypes:[Any.Type?] {
        compactMap { type(of: $0.value.flowRepresentableFactory().underlyingInstance) }
    }
}
