//
//  WorkflowListener.swift
//  Workflow
//
//  Created by Tyler Thompson on 5/9/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

public func XCTAssertWorkflowLaunched(listener: WorkflowListener, expectedFlowRepresentables:[AnyFlowRepresentable.Type]) {
    XCTAssertNotNil(listener.workflow, "No workflow found")
    guard let workflow = listener.workflow, expectedFlowRepresentables.count == workflow.count else {
        XCTFail("workflow does not contain correct representables: \(String(describing: listener.workflow?.compactMap { String(describing: $0.value.flowRepresentableType) }) )")
        return
    }
    XCTAssertEqual(workflow.compactMap { String(describing: $0.value.flowRepresentableType) },
                   expectedFlowRepresentables.map { String(describing: $0) })
}

public class WorkflowListener {
    public var workflow:Workflow?
    public var launchStyle:PresentationType?
    public var args:Any?
    public var launchedFrom:AnyFlowRepresentable?
    public var onFinish:((Any?) -> Void)?
    
    public init() {
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
