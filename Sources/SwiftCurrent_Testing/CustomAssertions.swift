//
//  CustomAssertions.swift
//  
//
//  Created by Tyler Thompson on 8/8/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest

@testable import SwiftCurrent
@testable import SwiftCurrent_UIKit
@testable import SwiftCurrent_SwiftUI

/// Assert that a workflow was launched and matches the workflow passed in
public func XCTAssertWorkflowLaunched<F>(from VC: UIViewController, workflow: Workflow<F>, passedArgs: [AnyWorkflow.PassedArgs]) {
    let last = VC.launchedWorkflows.last
    XCTAssertNotNil(last, "No workflow found")
    guard let listenerWorkflow = last,
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
        let actual = type(of: node.value.metadata.flowRepresentableFactory(passedArgs[position]).underlyingInstance)
        guard let workflowNode = workflow.first?.traverse(node.position) else {
            XCTFail("expected workflow not as long as actual workflow")
            return
        }
        let expected = type(of: workflowNode.value.metadata.flowRepresentableFactory(passedArgs[position]).underlyingInstance)
        XCTAssert(actual == expected, "Expected type: \(expected), but got: \(actual)")
    }
}
