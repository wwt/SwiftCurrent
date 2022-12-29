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

    @Environment(\.shouldLoad) var envShouldLoad: Bool
    var shouldLoad: Bool {
        envShouldLoad && proxy.shouldLoad
    }

    @State private var content: Current
    @State private var wrapped: Next?

    @State private var hasProceeded = false
    @Environment(\.workflowHasProceeded) var envHasProceeded: Binding<Bool>?
    @Environment(\.presentationMode) var presentation

    @State private var args: AnyWorkflow.PassedArgs?
    @Environment(\.workflowArgs) var envArgs
    var passedArgs: AnyWorkflow.PassedArgs {
        args ?? envArgs
    }

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
            if shouldLoad && content._shouldLoad(args: passedArgs) {
                navigate(presentationType: launchStyle.wrappedValue, content: content, nextView: wrapped, isActive: $hasProceeded)
            } else {
                wrapped
            }
        }
        .environment(\.workflowProxy, proxy)
        .environment(\.workflowArgs, passedArgs)
        .environment(\.workflowHasProceeded, $hasProceeded)
        .onAppear(perform: setUpProxy)
        .onReceive(proxy.proceedPublisher, perform: proceed(_:))
        .onReceive(proxy.backupPublisher, perform: backUp)
        .onReceive(proxy.abandonPublisher, perform: abandon)
        .onReceive(proxy.onFinishPublisher, perform: finish(_:))
    }

    private func setUpProxy() {
        if proxy.shouldLoad && !content._shouldLoad(args: args ?? envArgs) {
            proxy.shouldLoad = false
        }
    }

    private func proceed(_ newArgs: AnyWorkflow.PassedArgs) {
        guard let wrapped, wrapped._shouldLoad(args: newArgs) else {
            proxy.onFinishPublisher.send(newArgs)
            return
        }
        hasProceeded = true
        args = newArgs
    }

    private func backUp() {
        defer { dismiss() }
        if !envProxy.shouldLoad {
            try? envProxy.backUpInWorkflow()
        }
    }

    private func abandon() {
        hasProceeded = false
        envProxy.abandonWorkflow()
    }

    private func finish(_ args: AnyWorkflow.PassedArgs?) {
        guard args != nil else { return }
        envProxy.onFinishPublisher.send(args)
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
