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
    @Environment(\.workflowProxy) private var parentProxy: WorkflowProxy

    @Environment(\.shouldLoad) private var parentShouldLoad: Bool
    private var shouldLoad: Bool {
        parentShouldLoad && proxy.shouldLoad && content._shouldLoad(args: passedArgs)
    }

    @State var content: Current
    @State private var nextView: Next?

    @State private var hasProceeded = false
    @Environment(\.workflowHasProceeded) private var parentHasProceeded: Binding<Bool>?
    @Environment(\.presentationMode) private var presentation
    @Environment(\.forwardProxyCalls) private var forwardProxyCalls

    @State private var args: AnyWorkflow.PassedArgs?
    private var parentArgs: AnyWorkflow.PassedArgs? {
        parentProxy.passedArgs
    }
    @Environment(\.workflowArgs) private var environmentArgs
    var passedArgs: AnyWorkflow.PassedArgs {
        args ?? parentArgs ?? environmentArgs
    }

    init(content: Current) where Next == Never {
        _nextView = State(initialValue: nil)
        _content = State(initialValue: content)
    }

    init(content: Current, next: () -> Next) {
        _nextView = State(initialValue: next())
        _content = State(initialValue: content)
    }

    public var body: some View {
        Group {
            if shouldLoad {
                navigate(presentationType: launchStyle.wrappedValue, content: content, nextView: nextView, isActive: $hasProceeded)
            } else {
                nextView
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
        .onReceive(inspection.notice) { inspection.visit(self, $0) }
    }

    private func setUpProxy() {
        if proxy.shouldLoad && !content._shouldLoad(args: passedArgs) {
            proxy.shouldLoad = false
        }
    }

    func proceed(_ newArgs: AnyWorkflow.PassedArgs) {
        guard !forwardProxyCalls else { parentProxy.proceedInWorkflow(newArgs); return }
        guard let nextView, nextView._shouldLoad(args: newArgs) else {
            proxy.onFinishPublisher.send(newArgs)
            return
        }
        hasProceeded = true
        args = newArgs
    }

    private func backUp() {
        guard !forwardProxyCalls else { try? parentProxy.backUpInWorkflow(); return }
        defer { dismiss() }
        if !parentProxy.shouldLoad {
            try? parentProxy.backUpInWorkflow()
        }
    }

    private func abandon() {
        hasProceeded = false
        parentProxy.abandonWorkflow()
    }

    private func finish(_ args: AnyWorkflow.PassedArgs?) {
        guard args != nil else { return }
        parentProxy.onFinishPublisher.send(args)
    }

    private func dismiss() {
        if let parentHasProceeded {
            parentHasProceeded.wrappedValue = false
        } else {
            presentation.wrappedValue.dismiss()
        }
    }

    /// :nodoc: Protocol requirement.
    public func _shouldLoad(args: AnyWorkflow.PassedArgs) -> Bool {
        guard !content._shouldLoad(args: args) else { return true }
        guard let nextView else { return false }
        return nextView._shouldLoad(args: args)
    }
}
