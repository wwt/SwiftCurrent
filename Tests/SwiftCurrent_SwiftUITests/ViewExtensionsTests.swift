//
//  ViewExtensionsTests.swift
//  
//
//  Created by Brian Lombardo on 8/24/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI
import XCTest
import SwiftCurrent
import SwiftCurrent_SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class ViewExtensionsTests: XCTestCase, View {

    func testThenProceedReturnsWorkflowItemForProvidedType() throws {
        struct FR1 : View, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }

        let item: Any = thenProceed(with: FR1.self)
        XCTAssert(item is WorkflowItem<FR1, Never, FR1>)
    }

    func testThenProceedWithNextItemReturnsWorkflowItemForProvidedType() throws {
        struct FR1 : View, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }

        struct FR2 : View, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text(String(describing: Self.self)) }
        }

        let item: Any = thenProceed(with: FR1.self) {
            thenProceed(with: FR2.self)
        }
        XCTAssert(item is WorkflowItem<FR1, WorkflowItem<FR2, Never, FR2>, FR1>)
    }
}
