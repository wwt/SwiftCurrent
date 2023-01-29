//
//  BackUpInWorkflowModifier.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 1/28/23.
//  Copyright © 2023 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct BackUpInWorkflowModifier: ViewModifier {
    @Binding var shouldBackUp: Bool
    @Environment(\.workflowProxy) var proxy

    public func body(content: Content) -> some View {
        content
            .onAppear {
                if shouldBackUp {
                    defer { shouldBackUp = false }
                    proxy.backUpInWorkflow()
                }
            }
            .onChange(of: shouldBackUp) {
                guard $0 else { return }
                defer { shouldBackUp = false }
                proxy.backUpInWorkflow()
            }
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension View {
    /// Subscribes to a combine publisher, when a value is emitted the workflow will abandon.
    public func backUpInWorkflow(_ shouldBackUp: Binding<Bool>) -> some View {
        modifier(BackUpInWorkflowModifier(shouldBackUp: shouldBackUp))
    }
}
