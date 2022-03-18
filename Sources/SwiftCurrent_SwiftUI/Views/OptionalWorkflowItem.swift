//
//  OptionalWorkflowItem.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 3/17/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent

#warning("Needs tests when used in nav stacks and modals")
/// :nodoc: ResultBuilder requirement.
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct OptionalWorkflowItem<WI: _WorkflowItemProtocol>: View, _WorkflowItemProtocol {
    /// :nodoc: Protocol requirement.
    public typealias F = WI.F // swiftlint:disable:this type_name

    @State var content: WI?

    /// :nodoc: Protocol requirement.
    public var body: some View {
        content
    }

    init(content: WI?) {
        _content = State(initialValue: content)
    }

    /// :nodoc: Protocol requirement.
    public func canDisplay(_ element: AnyWorkflow.Element?) -> Bool {
        content?.canDisplay(element) ?? false
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension OptionalWorkflowItem {
    /// :nodoc: Protocol requirement.
    public func modify(workflow: AnyWorkflow) {
        content?.modify(workflow: workflow)
    }

    /// :nodoc: Protocol requirement.
    public var workflowLaunchStyle: LaunchStyle.SwiftUI.PresentationType {
        content?.workflowLaunchStyle ?? .default
    }
}
