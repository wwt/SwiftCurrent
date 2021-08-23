//
//  WorkflowItemExtensions.swift
//  SwiftCurrent_SwiftUITests
//
//  Created by Tyler Thompson on 8/23/21.
//

import XCTest
import SwiftUI

import ViewInspector

@testable import SwiftCurrent_SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowItem {
    @discardableResult func inspectWrapped<F, W, C>(inspection: @escaping (InspectableView<ViewType.View<Wrapped>>) throws -> Void) throws -> XCTestExpectation where Wrapped == WorkflowItem<F, W, C> {
        let wrapped = try XCTUnwrap((Mirror(reflecting: self).descendant("_wrapped") as? State<Wrapped?>)?.wrappedValue)
        // Waiting for 0.0 seems insane but think about it like "We are waiting for this command to get off the stack"
        // Then quit thinking about it, know it was deliberate, and move on.
        let expectation = wrapped.inspection.inspect(after: 0.0, inspection)
        defer {
            XCTWaiter().wait(for: [expectation], timeout: 0.0)
        }
        return expectation
    }
}
