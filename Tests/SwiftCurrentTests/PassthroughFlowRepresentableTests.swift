//
//  PassthroughFlowRepresentableTests.swift
//  
//
//  Created by Richard Gist on 7/27/21.
//

import Foundation
import XCTest

import SwiftCurrent

class PassthroughFlowRepresentableTests: XCTestCase {
    func testProceedInWorkflowFatalErrorsWhenNotInWorkflow() throws {
        struct FR1: PassthroughFlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?
        }
        let passthrough = FR1()

        try XCTAssertThrowsFatalError {
            passthrough.proceedInWorkflow()
        }
    }
}
