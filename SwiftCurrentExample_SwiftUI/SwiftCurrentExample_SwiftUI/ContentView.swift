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
    var workflow: Workflow = Workflow(FR1.self)
    var body: some View {
        Text("Hello, world!")
            .padding()
        SwiftUIResponder()
            .padding()
        SwiftUIResponder2(workflow: workflow)
        .padding()
    }
}

struct FR1: View, FlowRepresentable {
    weak var _workflowPointer: AnyFlowRepresentable?


    var body: some View {
        Text("FR1")
        Button("Abandon!") {
            self.workflow?.abandon()
        }
        .padding()
    }
}
