//
//  CustomAssertions.swift
//  
//
//  Created by Tyler Thompson on 8/8/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

#if canImport(XCTest) && canImport(UIKit)
import XCTest
import UIKit

@testable import SwiftCurrent

/// Assert that a workflow was launched and matches the workflow passed in
public func XCTAssertWorkflowLaunched<F>(from VC: UIViewController, workflow: Workflow<F>, file: StaticString = #filePath, line: UInt = #line) {
    let last = VC.launchedWorkflows.last
    XCTAssertNotNil(last, "No workflow found", file: file, line: line)
    guard let listenerWorkflow = last,
          listenerWorkflow.count == workflow.count else {
        XCTFail("workflow does not contain correct representables", file: file, line: line)
        return
    }

    for node in listenerWorkflow {
        let actual = node.value.metadata.flowRepresentableTypeDescriptor
        guard let workflowNode = workflow.first?.traverse(node.position) else {
            XCTFail("expected workflow not as long as actual workflow", file: file, line: line)
            return
        }
        let expected = workflowNode.value.metadata.flowRepresentableTypeDescriptor
        XCTAssert(actual == expected, "Expected type: \(expected), but got: \(actual)", file: file, line: line)
    }
}
#endif
