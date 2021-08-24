//
//  ViewExtensionsTests.swift
//  
//
//  Created by Brian Lombardo on 8/24/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import SwiftCurrent
import SwiftCurrent_SwiftUI
import SwiftUI
import XCTest

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
class ViewExtensionsTests: XCTestCase {
    func testThenProceedReturnsWorkflowItemForProvidedType() throws {
        struct TestView : View, FlowRepresentable {
            weak var _workflowPointer: AnyFlowRepresentable?
            var body: some View { Text("test") }
        }

        let item: Any = TestView().thenProceed(with: TestView.self)
        XCTAssert(item is WorkflowItem<TestView, Never, TestView>)
    }
}
