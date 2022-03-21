//
//  ContentView.swift
//  SwiftCurrent
//
//  Created by Nick Kaczmarek on 3/16/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent

struct ContentView: View, FlowRepresentable, WorkflowDecodable {
    var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        VStack {
            Text(String(describing: Self.self))
            Button("Go forward") {
                proceedInWorkflow()
            }
            Button("Go back") {
                try? backUpInWorkflow()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
