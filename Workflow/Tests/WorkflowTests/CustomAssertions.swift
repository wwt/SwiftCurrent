//
//  CustomAssertions.swift
//  WorkflowTests
//
//  Created by Tyler Thompson on 9/2/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
@testable import CwlPreconditionTesting

func XCTAssertThrowsFatalError(instructions: @escaping () -> Void) {
    var reached = false
    let exception = catchBadInstruction {
        instructions()
        reached = true
    }
    XCTAssertNotNil(exception, "No fatal error thrown")
    XCTAssertFalse(reached, "Code executed past expected fatal error")
}
