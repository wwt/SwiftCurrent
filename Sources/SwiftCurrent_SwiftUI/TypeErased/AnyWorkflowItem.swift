//
//  AnyWorkflowItem.swift
//  SwiftCurrent
//
//  Created by Morgan Zellers on 11/2/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct AnyWorkflowItem: View, _WorkflowItemProtocol {
    public var workflowLaunchStyle: LaunchStyle.SwiftUI.PresentationType {
        .default
    }

    public typealias FlowRepresentableType = Never

    public func canDisplay(_ element: AnyWorkflow.Element?) -> Bool {
        false
    }

    public func modify(workflow: AnyWorkflow) {

    }

    let inspection = Inspection<Self>()
    private let _body: AnyView

    public var body: some View {
        _body.onReceive(inspection.notice) { inspection.visit(self, $0) }
    }

    init<W: _WorkflowItemProtocol>(view: W) {
        _body = AnyView(view)
    }
}
