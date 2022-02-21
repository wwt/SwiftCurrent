//
//  WorkflowView.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 2/21/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

#warning("REVISIT: Can we extend `Workflow` to do this?")
#warning("REVISIT THE REVISIT: ... should we?")

import SwiftUI
import SwiftCurrent

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
struct WorkflowView<Content: View>: View {
    @StateObject private var model: WorkflowViewModel
    @StateObject private var launcher: Launcher

    @State var content: Content
    @State private var onFinish = [(AnyWorkflow.PassedArgs) -> Void]()
    @State private var onAbandon = [() -> Void]()
    @State private var shouldEmbedInNavView = false

    let inspection = Inspection<Self>()

    var body: some View {
        content
            .environmentObject(model)
            .environmentObject(launcher)
            .onReceive(model.onFinishPublisher, perform: _onFinish)
            .onReceive(inspection.notice) { inspection.visit(self, $0) }
    }

    init<F, W, C>(@WorkflowBuilder builder: () -> Content) where Content == WorkflowItem<F, W, C> {
        self.init(startingArgs: .none, content: builder())
    }

    private init<F, W, C>(startingArgs: AnyWorkflow.PassedArgs, content: Content) where Content == WorkflowItem<F, W, C> {
        let wf = AnyWorkflow.empty
        content.modify(workflow: wf)
        let model = WorkflowViewModel(isLaunched: .constant(true), launchArgs: startingArgs)
        _model = StateObject(wrappedValue: model)
        _launcher = StateObject(wrappedValue: Launcher(workflow: wf,
                                                       responder: model,
                                                       launchArgs: startingArgs))
        _content = State(wrappedValue: content)
    }

    private init(_ other: Self, onFinish: [(AnyWorkflow.PassedArgs) -> Void]) {
        _content = other._content
        _onFinish = State(initialValue: onFinish)
        _model = other._model
        _launcher = other._launcher
    }

    private func _onFinish(_ args: AnyWorkflow.PassedArgs?) {
        guard let args = args else { return }
        onFinish.forEach { $0(args) }
    }

    func onFinish(_ closure: @escaping (AnyWorkflow.PassedArgs) -> Void) -> Self {
        var onFinish = onFinish
        onFinish.append(closure)
        return Self(self, onFinish: onFinish)
    }
}
