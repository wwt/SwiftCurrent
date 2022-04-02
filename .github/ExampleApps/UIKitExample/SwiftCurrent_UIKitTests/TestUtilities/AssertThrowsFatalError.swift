//
//  AssertThrowsFatalError.swift
//  WorkflowTests
//
//  Created by Tyler Thompson on 9/2/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import CwlPreconditionTesting

func XCTAssertThrowsFatalError(instructions: @escaping () -> Void, file: StaticString = #file, line: UInt = #line) throws {
    #if (os(macOS) || os(iOS)) && arch(x86_64)
    var reached = false
    let exception = catchBadInstruction {
        instructions()
        reached = true
    }
    XCTAssertNotNil(exception, "No fatal error thrown", file: file, line: line)
    XCTAssertFalse(reached, "Code executed past expected fatal error", file: file, line: line)
    #else
    throw XCTSkip("XCTAssertThrowsFatalError is only available on macOS/iOS on x86_64 architecture.")
    #endif
}
