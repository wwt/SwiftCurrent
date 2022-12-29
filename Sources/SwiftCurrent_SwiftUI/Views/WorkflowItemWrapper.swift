//
//  WorkflowItemWrapper.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 3/8/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent

/// :nodoc: ResultBuilder requirement.
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct WorkflowItemWrapper<Current: _WorkflowItemProtocol, Next: _WorkflowItemProtocol>: _WorkflowItemProtocol, Workflow {
    public var launchStyle: State<LaunchStyle.SwiftUI.PresentationType> { content.launchStyle }
    #warning("Needed?")
    let inspection = Inspection<Self>() // needed?

    @StateObject private var proxy = WorkflowProxy()
    @Environment(\.workflowProxy) var envProxy: WorkflowProxy

    @State private var shouldLoad = true
    @Environment(\.shouldLoad) var envShouldLoad: Bool

    @State private var content: Current
    @State private var wrapped: Next?

    @State private var hasProceeded = false
    @Environment(\.workflowHasProceeded) var envHasProceeded: Binding<Bool>?
    @Environment(\.presentationMode) var presentation

    @State private var args: AnyWorkflow.PassedArgs?
    @Environment(\.workflowArgs) var envArgs

    init(content: Current) where Next == Never {
        _wrapped = State(initialValue: nil)
        _content = State(initialValue: content)
    }

    init(content: Current, next: () -> Next) {
        _wrapped = State(initialValue: next())
        _content = State(initialValue: content)
    }

    public var body: some View {
        Group {
            if shouldLoad && envShouldLoad && content._shouldLoad(args: args ?? envArgs) {
                navigate(presentationType: launchStyle.wrappedValue, content: content, nextView: wrapped, isActive: $hasProceeded)
            } else {
                wrapped
            }
        }
        .onAppear {
            if proxy.shouldLoad && !content._shouldLoad(args: args ?? envArgs) {
                proxy.shouldLoad = false
            }
        }
        .environment(\.workflowProxy, proxy)
        .environment(\.workflowArgs, args ?? envArgs)
        .environment(\.workflowHasProceeded, $hasProceeded)
        .onReceive(proxy.proceedPublisher) {
            guard let wrapped, wrapped._shouldLoad(args: $0) else {
                proxy.onFinishPublisher.send($0)
                return
            }
            hasProceeded = true
            args = $0
        }
        .onReceive(proxy.$shouldLoad) {
            guard envShouldLoad else { return }
            shouldLoad = $0
        }
        .onReceive(proxy.backupPublisher) {
            defer { dismiss() }
            if !envProxy.shouldLoad {
                try? envProxy.backUpInWorkflow()
            }
        }
        .onReceive(proxy.abandonPublisher) {
            hasProceeded = false
            envProxy.abandonWorkflow()
        }
        .onReceive(proxy.onFinishPublisher) {
            guard $0 != nil else { return }
            envProxy.onFinishPublisher.send($0)
        }
    }

    private func dismiss() {
        if let envHasProceeded {
            envHasProceeded.wrappedValue = false
        } else {
            presentation.wrappedValue.dismiss()
        }
    }

    /// :nodoc: Protocol requirement.
    public func _shouldLoad(args: AnyWorkflow.PassedArgs) -> Bool {
        guard !content._shouldLoad(args: args) else { return true }
        guard let wrapped else { return false }
        return wrapped._shouldLoad(args: args)
    }
}
