//
//  _OptionalWorkflowItem.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 2/23/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
// swiftlint:disable:next type_name
public struct _OptionalWorkflowItem<WI: _WorkflowItemProtocol>: _WorkflowItemProtocol, WorkflowModifier, WorkflowItemPresentable {
    public typealias F = WI.F // swiftlint:disable:this type_name

    public typealias Wrapped = WI.Wrapped

    public typealias Content = WI.Content

    var workflowLaunchStyle: LaunchStyle.SwiftUI.PresentationType { (workflowItem as? WorkflowItemPresentable)?.workflowLaunchStyle ?? .default }

    let workflowItem: WI?

    public var body: some View {
        if let workflowItem = workflowItem {
            workflowItem
        }
    }

    init(workflowItem: WI?) {
        self.workflowItem = workflowItem
    }

    public init?() {
        workflowItem = nil
    }

    func modify(workflow: AnyWorkflow) {
        if let workflowItem = workflowItem {
            (workflowItem as? WorkflowModifier)?.modify(workflow: workflow)
        } else {
            (Wrapped() as? WorkflowModifier)?.modify(workflow: workflow)
        }
    }
}
