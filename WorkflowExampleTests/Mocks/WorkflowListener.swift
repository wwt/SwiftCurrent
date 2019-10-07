//
//  WorkflowListener.swift
//  WorkflowExampleTests
//
//  Created by Tyler Thompson on 10/5/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import DynamicWorkflow

class WorkflowListener {
    var workflow:Workflow?
    var launchStyle:PresentationType?
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
        workflow = dict?["workflow"] as? Workflow
        launchStyle = dict?["style"] as? PresentationType
        onFinish = dict?["onFinish"] as? ((Any?) -> Void)
        launchedFrom = dict?["launchFrom"] as? AnyFlowRepresentable
        args = dict?["args"] as Any?
    }
}

func XCTAssertWorkflowLaunched(listener: WorkflowListener, expectedFlowRepresentables:[AnyFlowRepresentable.Type]) {
    XCTAssertNotNil(listener.workflow, "No workflow found")
    guard let workflow = listener.workflow, expectedFlowRepresentables.count == workflow.count else {
        XCTFail("workflow does not contain correct representables: \(String(describing: listener.workflow?.compactMap { String(describing: $0.value) }) )")
        return
    }
    XCTAssertEqual(workflow.compactMap { String(describing: $0.value) },
                   expectedFlowRepresentables.map { String(describing: $0) })
}
