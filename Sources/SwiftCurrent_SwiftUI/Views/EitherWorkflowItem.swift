//
//  EitherWorkflowItem.swift
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
public struct EitherWorkflowItem<W0: _WorkflowItemProtocol, W1: _WorkflowItemProtocol>: View, _WorkflowItemProtocol where W0.F.WorkflowInput == W1.F.WorkflowInput {
    /// :nodoc: Protocol requirement.
    public typealias F = W0.F // swiftlint:disable:this type_name

    @State var first: W0?
    @State var second: W1?

    /// :nodoc: Protocol requirement.
    public var body: some View {
        ViewBuilder {
            if let first = first {
                first
            } else {
                second
            }
        }
    }

    /// :nodoc: Protocol requirement.
    public func canDisplay(_ element: AnyWorkflow.Element?) -> Bool {
        first?.canDisplay(element) ?? second?.canDisplay(element) ?? false
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension EitherWorkflowItem {
    /// :nodoc: Protocol requirement.
    public func modify(workflow: AnyWorkflow) {
        first?.modify(workflow: workflow)
        second?.modify(workflow: workflow)
    }

    /// :nodoc: Protocol requirement.
    public var workflowLaunchStyle: LaunchStyle.SwiftUI.PresentationType {
        first?.workflowLaunchStyle ?? second?.workflowLaunchStyle ?? .default
    }
}
