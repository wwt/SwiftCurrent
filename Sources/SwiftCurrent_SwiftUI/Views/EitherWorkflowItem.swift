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
public struct EitherWorkflowItem<W0: _WorkflowItemProtocol, W1: _WorkflowItemProtocol>: View, _WorkflowItemProtocol {
    enum Either<First, Second>: View where First: _WorkflowItemProtocol, Second: _WorkflowItemProtocol {
        var presentationType: State<SwiftCurrent.LaunchStyle.SwiftUI.PresentationType> {
            switch self {
                case .first(let first): return first.launchStyle
                case .second(let second): return second.launchStyle
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

        func shouldLoad(args: AnyWorkflow.PassedArgs) -> Bool {
            switch self {
                case .first(let first): return first._shouldLoad(args: args)
                case .second(let second): return second._shouldLoad(args: args)
            }
        }
    }

    @State var content: Either<W0, W1>

    /// :nodoc: Protocol requirement.
    public var body: some View {
        content
    }

    /// :nodoc: Protocol requirement.
    public var launchStyle: State<SwiftCurrent.LaunchStyle.SwiftUI.PresentationType> {
        content.presentationType
    }

    /// :nodoc: Protocol requirement.
    public func _shouldLoad(args: AnyWorkflow.PassedArgs) -> Bool {
        content.shouldLoad(args: args)
    }
}
