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
    @State var content: Content
    @State private var onFinish = [(AnyWorkflow.PassedArgs) -> Void]()
    @State private var onAbandon = [() -> Void]()
    @State private var shouldEmbedInNavView = false

    let inspection = Inspection<Self>()

    var body: some View {
        content
            .onReceive(inspection.notice) { inspection.visit(self, $0) }
    }

    init<F, W, C>(@WorkflowBuilder builder: () -> WorkflowItem<F, W, C>) where Content == WorkflowLauncher<WorkflowItem<F, W, C>>, F.WorkflowInput == Never {
        self.init(startingArgs: .none, content: builder())
    }

    private init<F, W, C>(startingArgs: AnyWorkflow.PassedArgs, content: WorkflowItem<F, W, C>) where Content == WorkflowLauncher<WorkflowItem<F, W, C>>, F.WorkflowInput == Never {
        _content = State(wrappedValue: WorkflowLauncher(isLaunched: .constant(true)) { content })
    }

    private init<F, W, C>(_ other: WorkflowView<Content>, newContent: Content, onFinish: [(AnyWorkflow.PassedArgs) -> Void]) where Content == WorkflowLauncher<WorkflowItem<F, W, C>> {
        _content = State(wrappedValue: newContent)
        _onFinish = State(initialValue: onFinish)
    }

    func onFinish<F, W, C>(_ closure: @escaping (AnyWorkflow.PassedArgs) -> Void) -> Self where Content == WorkflowLauncher<WorkflowItem<F, W, C>> {
        var onFinish = onFinish
        onFinish.append(closure)
        return Self(self, newContent: _content.wrappedValue.onFinish(closure: closure), onFinish: onFinish)
    }
}
