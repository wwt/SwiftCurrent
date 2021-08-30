//
//  AnyFlowRepresentableViewTests.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Tyler Thompson on 7/13/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import SwiftUI

import SwiftCurrent

@testable import SwiftCurrent_SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class AnyFlowRepresentableViewTests: XCTestCase, View {
    override func tearDownWithError() throws {
        removeQueuedExpectations()
    }

    func testAnyFlowRepresentableViewDoesNotCreate_StrongRetainCycle() {
        var afrv: AnyFlowRepresentableView?
        weak var ref: AnyFlowRepresentableView?
        afrv = AnyFlowRepresentableView(type: FR.self, args: .none)
        ref = afrv
        XCTAssertNotNil(afrv)
        XCTAssertNotNil(ref)
        afrv = nil
        XCTAssertNil(afrv)
        XCTAssertNil(ref)
    }

    func testAnyFlowRepresentableViewDoesNotCreate_StrongRetainCycle_WhenUnderlyingViewIsChanged() {
        var afrv: AnyFlowRepresentableView?
        weak var ref: AnyFlowRepresentableView?
        afrv = AnyFlowRepresentableView(type: FR.self, args: .none)
        afrv?.changeUnderlyingView(to: EmptyView())
        ref = afrv
        XCTAssertNotNil(afrv)
        XCTAssertNotNil(ref)
        afrv = nil
        XCTAssertNil(afrv)
        XCTAssertNil(ref)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
fileprivate struct FR: View, FlowRepresentable {
    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        EmptyView()
    }
}
