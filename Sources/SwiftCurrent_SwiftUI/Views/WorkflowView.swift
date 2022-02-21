//
//  WorkflowView.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 2/21/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
struct WorkflowView<Content: View>: View {
    @State var content: Content

    let inspection = Inspection<Self>()

    var body: some View {
        content
            .onReceive(inspection.notice) { inspection.visit(self, $0) }
    }

    init<F, W, C>(isLaunched: Binding<Bool> = .constant(true),
                  @WorkflowBuilder builder: () -> WorkflowItem<F, W, C>) where Content == WorkflowLauncher<WorkflowItem<F, W, C>>, F.WorkflowInput == Never {
        self.init(isLaunched: isLaunched, startingArgs: .none, content: builder())
    }

    init<F, W, C>(isLaunched: Binding<Bool> = .constant(true),
                  launchingWith args: F.WorkflowInput,
                  @WorkflowBuilder content: () -> WorkflowItem<F, W, C>) where Content == WorkflowLauncher<WorkflowItem<F, W, C>> {
        self.init(isLaunched: isLaunched, startingArgs: .args(args), content: content())
    }

    init<F, W, C>(isLaunched: Binding<Bool> = .constant(true),
                  launchingWith args: AnyWorkflow.PassedArgs,
                  @WorkflowBuilder content: () -> WorkflowItem<F, W, C>) where Content == WorkflowLauncher<WorkflowItem<F, W, C>>, F.WorkflowInput == AnyWorkflow.PassedArgs {
        self.init(isLaunched: isLaunched, startingArgs: args, content: content())
    }

    init<A, F, W, C>(isLaunched: Binding<Bool> = .constant(true),
                     launchingWith args: A,
                     @WorkflowBuilder content: () -> WorkflowItem<F, W, C>) where Content == WorkflowLauncher<WorkflowItem<F, W, C>>, F.WorkflowInput == AnyWorkflow.PassedArgs {
        self.init(isLaunched: isLaunched, startingArgs: .args(args), content: content())
    }

    private init<F, W, C>(isLaunched: Binding<Bool>,
                          startingArgs: AnyWorkflow.PassedArgs,
                          content: WorkflowItem<F, W, C>) where Content == WorkflowLauncher<WorkflowItem<F, W, C>> {
        _content = State(wrappedValue: WorkflowLauncher(isLaunched: isLaunched, startingArgs: startingArgs) { content })
    }

    private init<F, W, C>(_ other: WorkflowView<Content>,
                          newContent: Content) where Content == WorkflowLauncher<WorkflowItem<F, W, C>> {
        _content = State(wrappedValue: newContent)
    }

    func onFinish<F, W, C>(_ closure: @escaping (AnyWorkflow.PassedArgs) -> Void) -> Self where Content == WorkflowLauncher<WorkflowItem<F, W, C>> {
        Self(self, newContent: _content.wrappedValue.onFinish(closure: closure))
    }

    func onAbandon<F, W, C>(_ closure: @escaping () -> Void) -> Self where Content == WorkflowLauncher<WorkflowItem<F, W, C>> {
        Self(self, newContent: _content.wrappedValue.onAbandon(closure: closure))
    }
}
