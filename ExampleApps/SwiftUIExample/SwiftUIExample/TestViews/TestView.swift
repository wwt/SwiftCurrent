//
//  TestView.swift
//  SwiftUIExample
//
//  Created by Richard Gist on 9/1/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        if let testingView = ProcessInfo.processInfo.environment[EnvironmentKey.testingView.rawValue] {
            switch TestingView(rawValue: testingView) {
                case .FR1: FR1()
                default: Text("\(String(describing: ProcessInfo.processInfo.environment[EnvironmentKey.stringData.rawValue]))")
            }
        } else {
            Text("\(String(describing: ProcessInfo.processInfo.environment[EnvironmentKey.stringData.rawValue]))")
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

import SwiftCurrent
struct FR1: View, FlowRepresentable {
    weak var _workflowPointer: AnyFlowRepresentable?
    var body: some View {
        VStack {
            Text("This is \(String(describing: Self.self))")
            Button("Navigate forward") { proceedInWorkflow() }
        }
    }
}
