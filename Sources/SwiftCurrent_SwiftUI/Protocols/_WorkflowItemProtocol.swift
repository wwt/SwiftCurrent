//
//  _WorkflowItemProtocol.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 2/23/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent

/// :nodoc: Protocol is forced to be public, but it is an internal protocol.
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public protocol _WorkflowItemProtocol: View where FlowRepresentableType: FlowRepresentable & View {
    associatedtype FlowRepresentableType

    var workflowLaunchStyle: LaunchStyle.SwiftUI.PresentationType { get }

    func canDisplay(_ element: AnyWorkflow.Element?) -> Bool
    mutating func setElementRef(_ element: AnyWorkflow.Element?)
    func modify(workflow: AnyWorkflow)
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension _WorkflowItemProtocol {
    /// :nodoc: Protocol requirement.
    public func setElementRef(_ element: AnyWorkflow.Element?) { }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension Never: _WorkflowItemProtocol {
    /// :nodoc: Protocol requirement.
    public typealias FlowRepresentableType = Never

    /// :nodoc: Protocol requirement.
    public typealias Content = Never

    /// :nodoc: Protocol requirement.
    public var workflowLaunchStyle: LaunchStyle.SwiftUI.PresentationType { .default }

    /// :nodoc: Protocol requirement.
    public func canDisplay(_ element: AnyWorkflow.Element?) -> Bool { false }
    /// :nodoc: Protocol requirement.
    public func modify(workflow: AnyWorkflow) { }
}
