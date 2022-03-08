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
public struct WorkflowGroup<Content: _WorkflowItemProtocol>: View, _WorkflowItemProtocol {
    public init?() { nil }

    public typealias F = Content.F // swiftlint:disable:this type_name

    public typealias Content = Content.Content

    @State var content: Content

    public var body: some View {
        content
    }

    public init(@WorkflowBuilder content: () -> Content) {
        _content = State(initialValue: content())
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowGroup: WorkflowModifier {
    func modify(workflow: AnyWorkflow) {
        (content as? WorkflowModifier)?.modify(workflow: workflow)
    }
}
