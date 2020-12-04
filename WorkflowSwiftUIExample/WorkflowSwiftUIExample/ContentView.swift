//
//  ContentView.swift
//  WorkflowSwiftUIExample
//
//  Created by Tyler Thompson on 11/29/20.
//

import SwiftUI
import Workflow
import WorkflowSwiftUI

struct ContentView: View {
    var body: some View {
        Text("Above")
        WorkflowView(Workflow(FR1.self)
                        .thenPresent(FR2.self, presentationType: .modal)
                        .thenPresent(FR3.self, presentationType: .modal), withLaunchStyle: .modal)
        Text("Below")
    }
}

struct Wrapper: View {
    @State var showingModal = true

    let _content: AnyView
    let _next: AnyView

    init(next: AnyView, content: AnyView) {
        _next = next
        _content = content
    }

    var body: some View {
        _content.sheet(isPresented: $showingModal, content: {
            _next
        })
    }
}

struct FR1: View, FlowRepresentable {
    var _workflowPointer: AnyFlowRepresentable?

    static func instance() -> Self { Self() }

    var body: some View {
        Text("\(String(describing: Self.self))")
            .padding()
        Button("Proceed", action: proceedInWorkflow)
    }
}

struct FR2: View, FlowRepresentable {
    var _workflowPointer: AnyFlowRepresentable?

    static func instance() -> Self { Self() }

    var body: some View {
        Text("\(String(describing: Self.self))")
            .padding()
        Button("Proceed", action: proceedInWorkflow)
        Button("Back", action: proceedBackwardInWorkflow)
    }
}

struct FR3: View, FlowRepresentable {
    var _workflowPointer: AnyFlowRepresentable?

    static func instance() -> Self { Self() }

    var body: some View {
        Text("\(String(describing: Self.self))")
            .padding()
        Button("Back", action: proceedBackwardInWorkflow)
        Button("Abandon") {
            workflow?.abandon()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
