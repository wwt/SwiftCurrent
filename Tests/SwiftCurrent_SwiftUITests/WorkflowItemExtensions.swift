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
    func getWrappedView() throws -> Wrapped {
        try XCTUnwrap((Mirror(reflecting: self).descendant("_wrapped") as? State<Wrapped?>)?.wrappedValue)
    }
}
