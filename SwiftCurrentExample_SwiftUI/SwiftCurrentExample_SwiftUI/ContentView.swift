//
//  ContentView.swift
//  SwiftCurrentExample_SwiftUI
//
//  Created by Richard Gist on 6/21/21.
//

import SwiftUI

import SwiftCurrent
import SwiftCurrent_SwiftUI

struct ContentView: View {
    @State var state = false
    var workflow: Workflow = Workflow(FR1.self)
        .thenProceed(with: FR2.self)
    var workflow2: Workflow = Workflow(FR1.self)
        .thenProceed(with: FR2.self)

    var body: some View {
        Text("Hello, world!")
            .frame(maxWidth: .infinity, alignment:state ? .leading : .trailing)
            .foregroundColor(state ? .red : .green)
        //            .padding()
        SwiftUIResponder()
        SwiftUIResponder2(workflow: workflow) { _ in
            withAnimation {    state.toggle()}
        }
        Button("Ciao!") { withAnimation { state.toggle() } }
        SwiftUIResponder2(workflow: workflow) { _ in
            workflow.abandon()
        }
        SwiftUIResponder2(workflow: workflow2) { _ in
            workflow2.abandon(animated: false)
        }
    }
}

struct FR1: View, FlowRepresentable {
    weak var _workflowPointer: AnyFlowRepresentable?

    @State var state = false

    var body: some View {
        VStack {
            Text("FR1")
            HStack {
                Button("Abandon!") {
                    self.workflow?.abandon()
                }
                Button("Proceed!") {
                    withAnimation { state.toggle() }
                    self.proceedInWorkflow()
                }
                Button("Backup!") {
                    withAnimation { state.toggle() }
                    try? self.backUpInWorkflow()
                }
            }
            .padding()
            Text("Hello, FR1!")
                .frame(maxWidth: .infinity, alignment: state ? .leading : .trailing)
                .foregroundColor(state ? .red : .green)
        }
    }
}

struct FR2: View, FlowRepresentable {
    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        Text("FR2")
        HStack {
            Button("Abandon!") {
                self.workflow?.abandon()
            }
            Button("Proceed!") {
                self.proceedInWorkflow()
            }
            Button("Backup!") {
                try? self.backUpInWorkflow()
            }
        }
        .padding()
    }
}
