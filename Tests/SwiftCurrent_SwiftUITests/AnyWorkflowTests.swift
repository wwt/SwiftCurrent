//
//  AnyWorkflowTests.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Tyler Thompson on 7/13/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import SwiftUI

import SwiftCurrent
import SwiftCurrent_SwiftUI

final class AnyWorkflowTests: XCTestCase {
    func testAbandonDoesNotBLOWUP() {
        let wf = Workflow(FR.self)
        AnyWorkflow(wf).abandon()
    }

    func testAbandonDoesNotBLOWUPOnTypedWorkflow() {
        Workflow(FR.self).abandon()
    }
}

fileprivate struct FR: View, FlowRepresentable {
    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        EmptyView()
    }
}
