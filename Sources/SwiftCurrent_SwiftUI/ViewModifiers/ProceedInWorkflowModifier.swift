//
//  ProceedModifier.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 1/2/23.
//  Copyright © 2023 WWT and Tyler Thompson. All rights reserved.
//  

import Combine
import SwiftUI
import SwiftCurrent

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct ProceedInWorkflowModifier<Pub: Publisher>: ViewModifier where Pub.Output == AnyWorkflow.PassedArgs, Pub.Failure == Never {
    @State var publisher: Pub
    @Environment(\.workflowProxy) var proxy

    public func body(content: Content) -> some View {
        content
            .onReceive(publisher, perform: proxy.proceedInWorkflow(_:))
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension View {
    /// Proceeds in the current workflow with a value.
    public func workflowLink(isPresented: Binding<Bool>, value: AnyWorkflow.PassedArgs) -> some View {
        WorkflowReader { proxy in
            self
                .onChange(of: isPresented.wrappedValue) {
                    guard $0 else { return }
                    proxy.proceedInWorkflow(value)
                    isPresented.wrappedValue = false
                }
        }
    }

    /// Proceeds in the current workflow with no value.
    public func workflowLink(isPresented: Binding<Bool>) -> some View {
        workflowLink(isPresented: isPresented, value: .none)
    }

    /// Proceeds in the current workflow with a value.
    public func workflowLink<T>(isPresented: Binding<Bool>, value: T) -> some View {
        workflowLink(isPresented: isPresented, value: .args(value))
    }
}
