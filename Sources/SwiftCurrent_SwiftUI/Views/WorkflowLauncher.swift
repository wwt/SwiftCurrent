//
//  WorkflowLauncher.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Tyler Thompson on 8/21/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI
import SwiftCurrent

/// :nodoc: WorkflowView requirement.
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct WorkflowLauncher<Content: _WorkflowItemProtocol>: View {
    public typealias WorkflowInput = Content.FlowRepresentableType.WorkflowInput

    @WorkflowBuilder private var content: Content
    @State private var onFinish = [(AnyWorkflow.PassedArgs) -> Void]()
    @State private var onAbandon = [() -> Void]()
    @State private var shouldEmbedInNavView = false
    @Binding private var isLaunched: Bool

    @StateObject private var model: WorkflowViewModel
    @StateObject private var launcher: Launcher

    let inspection = Inspection<Self>()

    public var body: some View {
        ViewBuilder {
            if isLaunched {
                if shouldEmbedInNavView {
                    NavigationView {
                        workflowContent
                    }.preferredNavigationStyle()
                } else {
                    workflowContent
                }
            }
        }
        .onChange(of: isLaunched) { if $0 == false { resetWorkflow() } }
    }

    private var workflowContent: some View {
        content
            .environmentObject(model)
            .environmentObject(launcher)
            .onReceive(model.onFinishPublisher, perform: _onFinish)
            .onReceive(model.onAbandonPublisher) { onAbandon.forEach { $0() } }
            .onReceive(inspection.notice) { inspection.visit(self, $0) }
    }

    init(isLaunched: Binding<Bool>, startingArgs: AnyWorkflow.PassedArgs, @WorkflowBuilder content: () -> Content) {
        _isLaunched = isLaunched
        let wf = AnyWorkflow.empty
        content().modify(workflow: wf)
        let model = WorkflowViewModel(isLaunched: isLaunched, launchArgs: startingArgs)
        _model = StateObject(wrappedValue: model)
        _launcher = StateObject(wrappedValue: Launcher(workflow: wf,
                                                       responder: model,
                                                       launchArgs: startingArgs))
        self.content = content()
    }

    private init(current: Self, shouldEmbedInNavView: Bool, onFinish: [(AnyWorkflow.PassedArgs) -> Void], onAbandon: [() -> Void]) {
        _model = current._model
        _launcher = current._launcher
        content = current.content
        _isLaunched = current._isLaunched
        _shouldEmbedInNavView = State(initialValue: shouldEmbedInNavView)
        _onFinish = State(initialValue: onFinish)
        _onAbandon = State(initialValue: onAbandon)
    }

    private func resetWorkflow() {
        launcher.workflow.launch(withOrchestrationResponder: model, passedArgs: launcher.launchArgs)
    }

    private func _onFinish(_ args: AnyWorkflow.PassedArgs?) {
        guard let args = args else { return }
        onFinish.forEach { $0(args) }
    }

    func onFinish(closure: @escaping (AnyWorkflow.PassedArgs) -> Void) -> Self {
        var onFinish = self.onFinish
        onFinish.append(closure)
        return Self(current: self, shouldEmbedInNavView: shouldEmbedInNavView, onFinish: onFinish, onAbandon: onAbandon)
    }

    func onAbandon(closure: @escaping () -> Void) -> Self {
        var onAbandon = self.onAbandon
        onAbandon.append(closure)
        return Self(current: self, shouldEmbedInNavView: shouldEmbedInNavView, onFinish: onFinish, onAbandon: onAbandon)
    }

    func embedInNavigationView() -> Self {
        Self(current: self, shouldEmbedInNavView: true, onFinish: onFinish, onAbandon: onAbandon)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension View {
    func preferredNavigationStyle() -> some View {
        #if (os(iOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst))
        return navigationViewStyle(StackNavigationViewStyle())
        #else
        return navigationViewStyle(DefaultNavigationViewStyle())
        #endif
    }
}
