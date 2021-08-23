//
//  WorkflowLauncherView.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Tyler Thompson on 8/21/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI
import SwiftCurrent

/**
 A view created by a `WorkflowLauncher`.

 ### Discussion
 You do not instantiate this view directly, rather you call `thenProceed(with:)` on a `WorkflowLauncher`.
 */
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct WorkflowLauncherView<Content: View>: View {
    @State private var content: Content
    @StateObject private var model: WorkflowViewModel
    @StateObject private var launcher: Launcher
    @State private var onFinish = [(AnyWorkflow.PassedArgs) -> Void]()
    @State private var onAbandon = [() -> Void]()

    let inspection = Inspection<Self>()

    public var body: some View {
        content
            .environmentObject(model)
            .environmentObject(launcher)
            .onReceive(model.onFinishPublisher, perform: _onFinish)
            .onReceive(model.onAbandonPublisher) { onAbandon.forEach { $0() } }
            .onReceive(inspection.notice) { inspection.visit(self, $0) }
    }

    init<A, F, W, C>(item: Content, workflowLauncher: WorkflowLauncher<A>) where Content == WorkflowItem<F, W, C> {
        let wf = AnyWorkflow.empty
        item.modify(workflow: wf)
        let model = WorkflowViewModel(isLaunched: workflowLauncher.$isLaunched, launchArgs: workflowLauncher.passedArgs)
        _model = StateObject(wrappedValue: model)
        _launcher = StateObject(wrappedValue: Launcher(workflow: wf,
                                                       responder: model,
                                                       launchArgs: workflowLauncher.passedArgs))
        _content = State(wrappedValue: item)
        _onFinish = State(initialValue: workflowLauncher.onFinish)
        _onAbandon = State(initialValue: workflowLauncher.onAbandon)
    }

    private init(current: Self, onFinish: [(AnyWorkflow.PassedArgs) -> Void], onAbandon: [() -> Void]) {
        _model = current._model
        _launcher = current._launcher
        _content = current._content
        _onFinish = State(initialValue: onFinish)
        _onAbandon = State(initialValue: onAbandon)
    }

    private func _onFinish(_ args: AnyWorkflow.PassedArgs?) {
        guard let args = args else { return }
        onFinish.forEach { $0(args) }
    }

    /// Adds an action to perform when this `Workflow` has finished.
    public func onFinish(closure: @escaping (AnyWorkflow.PassedArgs) -> Void) -> Self {
        var onFinish = self.onFinish
        onFinish.append(closure)
        return Self(current: self, onFinish: onFinish, onAbandon: onAbandon)
    }

    /// Adds an action to perform when this `Workflow` has abandoned.
    public func onAbandon(closure: @escaping () -> Void) -> Self {
        var onAbandon = self.onAbandon
        onAbandon.append(closure)
        return Self(current: self, onFinish: onFinish, onAbandon: onAbandon)
    }
}
