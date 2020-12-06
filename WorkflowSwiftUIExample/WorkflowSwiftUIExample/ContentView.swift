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
                        .thenPresent(FR2.self, presentationType: .navigationStack)
                        .thenPresent(FR3.self, presentationType: .navigationStack))
        Text("Below")
    }
}

struct FR1: View, FlowRepresentable {
    var _workflowPointer: AnyFlowRepresentable?

    static func instance() -> Self { Self() }

    var body: some View {
        VStack {
            Text("\(String(describing: Self.self))")
                .padding()
            Button("Proceed", action: proceedInWorkflow)
        }
    }
}

struct FR2: View, FlowRepresentable {
    var _workflowPointer: AnyFlowRepresentable?

    static func instance() -> Self { Self() }

    var body: some View {
        VStack {
            Text("\(String(describing: Self.self))")
                .padding()
            Button("Proceed", action: proceedInWorkflow)
            Button("Back", action: proceedBackwardInWorkflow)
        }
    }
}

struct FR3: View, FlowRepresentable {
    var _workflowPointer: AnyFlowRepresentable?

    static func instance() -> Self { Self() }

    var body: some View {
        VStack {
            Text("\(String(describing: Self.self))")
                .padding()
            Button("Back", action: proceedBackwardInWorkflow)
            Button("Abandon") {
                workflow?.abandon()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
