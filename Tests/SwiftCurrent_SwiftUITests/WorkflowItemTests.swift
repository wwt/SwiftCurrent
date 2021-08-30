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
final class WorkflowItemTests: XCTestCase, View {
    override func tearDownWithError() throws {
        removeQueuedExpectations()
    }

    func testWorkflowItemThrowsFatalError_IfPersistenceCannotBeCast() throws {
        let item = WorkflowItem(FR.self).persistence { _ in
            .default
        }
        
        let metadata = try XCTUnwrap((Mirror(reflecting: item).descendant("_metadata") as? State<FlowRepresentableMetadata?>)?.wrappedValue)

        try XCTAssertThrowsFatalError {
            _ = metadata.setPersistence(.args(1))
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
