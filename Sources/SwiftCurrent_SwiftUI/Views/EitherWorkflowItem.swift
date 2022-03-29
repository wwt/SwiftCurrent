//
//  EitherWorkflowItem.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 3/17/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent

/// :nodoc: ResultBuilder requirement.
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct EitherWorkflowItem<W0: _WorkflowItemProtocol, W1: _WorkflowItemProtocol>: View, _WorkflowItemProtocol where W0.FlowRepresentableType.WorkflowInput == W1.FlowRepresentableType.WorkflowInput {
    enum Either<First, Second>: View where First: _WorkflowItemProtocol, Second: _WorkflowItemProtocol {
        var workflowLaunchStyle: LaunchStyle.SwiftUI.PresentationType {
            switch self {
                case .first(let first): return first.workflowLaunchStyle
                case .second(let second): return second.workflowLaunchStyle
            }
        }

        func canDisplay(_ element: AnyWorkflow.Element?) -> Bool {
            switch self {
                case .first(let first): return first.canDisplay(element)
                case .second(let second): return second.canDisplay(element)
            }
        }

        func modify(workflow: AnyWorkflow) {
            switch self {
                case .first(let first): first.modify(workflow: workflow)
                case .second(let second): second.modify(workflow: workflow)
            }
        }

        case first(First)
        case second(Second)

        var body: some View {
            switch self {
                case .first(let first): first
                case .second(let second): second
            }
        }
    }

    /// :nodoc: Protocol requirement.
    public typealias FlowRepresentableType = W0.FlowRepresentableType

    @State var content: Either<W0, W1>

    /// :nodoc: Protocol requirement.
    public var body: some View {
        content
    }

    /// :nodoc: Protocol requirement.
    public func canDisplay(_ element: AnyWorkflow.Element?) -> Bool {
        content.canDisplay(element)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension EitherWorkflowItem {
    /// :nodoc: Protocol requirement.
    public func modify(workflow: AnyWorkflow) {
        content.modify(workflow: workflow)
    }

    /// :nodoc: Protocol requirement.
    public var workflowLaunchStyle: LaunchStyle.SwiftUI.PresentationType {
        content.workflowLaunchStyle
    }
}
