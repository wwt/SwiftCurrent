//
//  _WorkflowItemProtocol.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 2/23/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public protocol _WorkflowItemProtocol: View where F: FlowRepresentable & View, Content: View {
    associatedtype F // swiftlint:disable:this type_name
    associatedtype Content

    func canDisplay(_ element: AnyWorkflow.Element?) -> Bool
    mutating func setElementRef(_ element: AnyWorkflow.Element?)
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension _WorkflowItemProtocol {
    // swiftlint:disable:next missing_docs
    public func setElementRef(_ element: AnyWorkflow.Element?) { }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension Never: _WorkflowItemProtocol {
    public typealias F = Never // swiftlint:disable:this type_name

    public typealias Content = Never

    public func canDisplay(_ element: AnyWorkflow.Element?) -> Bool { false }
}
