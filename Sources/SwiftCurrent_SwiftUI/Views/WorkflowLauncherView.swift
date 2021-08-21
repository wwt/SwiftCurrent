//
//  WorkflowLauncherView.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Tyler Thompson on 8/21/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI
import SwiftCurrent

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

    init(item: Content,
         workflow: AnyWorkflow,
         isLaunched: Binding<Bool>,
         launchArgs: AnyWorkflow.PassedArgs,
         onFinish: [(AnyWorkflow.PassedArgs) -> Void],
         onAbandon: [() -> Void]) {
        let model = WorkflowViewModel(isLaunched: isLaunched, launchArgs: launchArgs)
        _model = StateObject(wrappedValue: model)
        _launcher = StateObject(wrappedValue: Launcher(workflow: workflow,
                                                       responder: model,
                                                       launchArgs: launchArgs))
        _content = State(wrappedValue: item)
        _onFinish = State(initialValue: onFinish)
        _onAbandon = State(initialValue: onAbandon)
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
