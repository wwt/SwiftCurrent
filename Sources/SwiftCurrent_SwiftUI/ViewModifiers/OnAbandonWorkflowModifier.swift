//
//  OnAbandonWorkflowModifier.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 12/29/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Combine
import SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct OnAbandonWorkflowModifier<Pub: Publisher>: ViewModifier where Pub.Failure == Never {
    @State var publisher: Pub
    @Environment(\.workflowProxy) var proxy

    public func body(content: Content) -> some View {
        content
            .onReceive(publisher) { _ in
                proxy.abandonWorkflow()
            }
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension View {
    /// Subscribes to a combine publisher, when a value is emitted the workflow will abandon.
    public func abandonWorkflowOn<T>(_ publisher: some Publisher<T, Never>) -> some View {
        modifier(OnAbandonWorkflowModifier(publisher: publisher))
    }
}
