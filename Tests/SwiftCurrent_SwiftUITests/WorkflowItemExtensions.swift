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
    @discardableResult func inspectWrapped<F, W, C>(function: String = #function, file: StaticString = #file, line: UInt = #line, inspection: @escaping (InspectableView<ViewType.View<Wrapped>>) throws -> Void) throws -> XCTestExpectation where Wrapped == WorkflowItem<F, W, C> {
        let wrapped = try XCTUnwrap((Mirror(reflecting: self).descendant("_wrapped") as? State<Wrapped?>)?.wrappedValue)
        return try wrapped.inspect(function: function, file: file, line: line, inspection: inspection)
    }

    @discardableResult func inspect(function: String = #function, file: StaticString = #file, line: UInt = #line, inspection: @escaping (InspectableView<ViewType.View<Self>>) throws -> Void) throws -> XCTestExpectation {
        // Waiting for 0.0 seems insane but think about it like "We are waiting for this command to get off the stack"
        // Then quit thinking about it, know it was deliberate, and move on.
        let expectation = self.inspection.inspect(after: 0, function: function, file: file, line: line) {
            try inspection($0)
        }
        XCTestCase.queuedExpectations.append(expectation)
        return expectation
    }

    @discardableResult func inspect(model: WorkflowViewModel, launcher: Launcher, function: String = #function, file: StaticString = #file, line: UInt = #line, inspection: @escaping (InspectableView<ViewType.View<Self>>) throws -> Void) throws -> XCTestExpectation {
        try ViewHosting.loadView(self, model: model, launcher: launcher).inspect(function: function, file: file, line: line, inspection: inspection)
    }

}
