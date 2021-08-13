//
//  WorkflowItemTests.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 7/13/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import SwiftUI

@testable import SwiftCurrent
@testable import SwiftCurrent_SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class WorkflowItemTests: XCTestCase {
    func testWorkflowItemThrowsFatalError_IfPersistenceCannotBeCast() throws {
        try XCTAssertThrowsFatalError {
            _ = WorkflowItem(FR.self).persistence { _ in
                    .default
            }.metadata.setPersistence(.args(1))
        }
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
fileprivate struct FR: View, FlowRepresentable {
    init(with args: String) { }
    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        EmptyView()
    }
}
