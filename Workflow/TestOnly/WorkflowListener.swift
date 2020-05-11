//
//  WorkflowListener.swift
//  Workflow
//
//  Created by Tyler Thompson on 5/9/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

#if DEBUG
import Foundation
import XCTest

public func XCTAssertWorkflowLaunched(listener: WorkflowListener, expectedFlowRepresentables:[AnyFlowRepresentable.Type], file: StaticString = #file, line: UInt = #line) {
    XCTAssertNotNil(listener.workflow, "No workflow found", file: file, line: line)
    guard let workflow = listener.workflow, expectedFlowRepresentables.count == workflow.count else {
        XCTFail("workflow does not contain correct representables: \(String(describing: listener.workflow?.compactMap { String(describing: $0.value.flowRepresentableType) }) )", file: file, line: line)
        return
    }
    XCTAssertEqual(workflow.compactMap { String(describing: $0.value.flowRepresentableType) },
                   expectedFlowRepresentables.map { String(describing: $0) }, file: file, line: line)
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
#endif
