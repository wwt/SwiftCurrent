//
//  ContentView.swift
//  WorkflowSwiftUIExample
//
//  Created by Morgan Zellers on 5/19/21.
//

import SwiftUI
import Workflow
import WorkflowSwiftUI

struct ContentView: View {
    let workflow = Workflow(FR1.self)
        .thenProceed(with: FR2.self)
    var body: some View {
        SwiftUIView(workflow: workflow)
    }
}


struct FR1: View, FlowRepresentable {
    var body: some View {
        Text("FR1")
        Button(action: {proceedInWorkflow()}, label: {
            Text("Button")
        })
    }
    public var _workflowPointer: AnyFlowRepresentable?
    
}

struct FR2: View, FlowRepresentable {
    var body: some View {
        Text("FR2")
    }
    
    public var _workflowPointer: AnyFlowRepresentable?
}
