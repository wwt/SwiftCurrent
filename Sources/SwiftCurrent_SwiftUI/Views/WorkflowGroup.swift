//
//  File.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 3/8/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct WorkflowGroup<WI: _WorkflowItemProtocol>: View, _WorkflowItemProtocol {
    public typealias F = WI.F // swiftlint:disable:this type_name

    @State var content: WI

    let inspection = Inspection<Self>()

    public var body: some View {
        content
            .onReceive(inspection.notice) { inspection.visit(self, $0) }
    }

    public init(@WorkflowBuilder content: () -> WI) {
        _content = State(initialValue: content())
    }

    public func canDisplay(_ element: AnyWorkflow.Element?) -> Bool {
        content.canDisplay(element)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowGroup {
    /// :nodoc: Protocol requirement.
    public func modify(workflow: AnyWorkflow) {
        content.modify(workflow: workflow)
    }

    /// :nodoc: Protocol requirement.
    public var workflowLaunchStyle: LaunchStyle.SwiftUI.PresentationType {
        content.workflowLaunchStyle
    }
}
