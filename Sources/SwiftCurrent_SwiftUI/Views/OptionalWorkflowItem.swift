//
//  OptionalWorkflowItem.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 3/17/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent

/// :nodoc: ResultBuilder requirement.
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct OptionalWorkflowItem<WI: _WorkflowItemProtocol>: View, _WorkflowItemProtocol {
    public var launchStyle: State<SwiftCurrent.LaunchStyle.SwiftUI.PresentationType> {
        content?.launchStyle ?? State(wrappedValue: .default)
    }
    @State var content: WI?

    /// :nodoc: Protocol requirement.
    public var body: some View {
        content
    }

    init(content: WI?) {
        _content = State(initialValue: content)
    }
}
