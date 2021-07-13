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

final class AnyFlowRepresentableViewTests: XCTestCase {
    func testAnyFlowRepresentableViewDoesNotCreate_StrongRetainCycle() {
        var afrv: AnyFlowRepresentableView?
        weak var ref: AnyFlowRepresentableView?
        autoreleasepool {
            afrv = AnyFlowRepresentableView(type: FR.self, args: .none)
            ref = afrv
            XCTAssertNotNil(afrv)
            XCTAssertNotNil(ref)
        }
        afrv = nil
        XCTAssertNil(afrv)
        XCTAssertNil(ref)
    }
}

fileprivate struct FR: View, FlowRepresentable {
    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        EmptyView()
    }
}
