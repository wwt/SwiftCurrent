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
    public var presentationType: State<SwiftCurrent.LaunchStyle.SwiftUI.PresentationType> { content.presentationType }

    @State var content: WI

    public var body: some View {
        content
    }

    public init(@WorkflowBuilder content: () -> WI) {
        _content = State(initialValue: content())
    }
}
