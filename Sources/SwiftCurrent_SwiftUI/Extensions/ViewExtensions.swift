//
//  ViewExtensions.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 12/24/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension View {
    public func shouldLoad(_ closure: @autoclosure () -> Bool) -> some View {
        WorkflowReader { _ in
            self
        }
        .environment(\.shouldLoad, closure())
    }

    public func shouldLoad(_ closure: () -> Bool) -> some View {
        WorkflowReader { _ in
            self
        }
        .environment(\.shouldLoad, closure())
    }

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

    public func workflowLink(isPresented: Binding<Bool>) -> some View {
        workflowLink(isPresented: isPresented, value: .none)
    }

    public func workflowLink<T>(isPresented: Binding<Bool>, value: T) -> some View {
        workflowLink(isPresented: isPresented, value: .args(value))
    }
}
