//
//  NavigationWorkflowLinkModifier.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 12/24/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct NavigationWorkflowLinkModifier<Wrapped: _WorkflowItemProtocol>: ViewModifier {
    @Environment(\.workflowArgs) var args
    @Environment(\.workflowProxy) var proxy

    @State var nextView: Wrapped?
    @Binding var isActive: Bool

    // Using a ViewBuilder here doesn't work due to a SwiftUI bug.
    // Short version, the only way the envrionment propagates correctly is if
    // You re-add whatever you want on `nextView` AND make sure you don't use
    // A BuildEither (if/else) block AND wrap it in something that displays, like a List.
    // This method circumvents the ViewBuilder using the `return` keyword.
    // Because the returns *must* be the same type, we're stuck with AnyView.
    public func body(content: Content) -> AnyView {
        let isActive = nextView == nil ? .constant(false) : $isActive
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return AnyView(
                content.navigationDestination(isPresented: isActive) { nextView.environment(\.workflowArgs, args).environment(\.workflowProxy, proxy) }
            )
        } else {
            return AnyView(
                content.background(
                    List {
                        NavigationLink(destination: nextView.environment(\.workflowArgs, args).environment(\.workflowProxy, proxy),
                                       isActive: $isActive) { EmptyView() }
                    }.opacity(0.01)
                )
            )
        }
    }
}
