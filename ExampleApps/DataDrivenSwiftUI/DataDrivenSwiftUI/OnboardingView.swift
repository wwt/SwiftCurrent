//
//  OnboardingView.swift
//  SwiftCurrent
//
//  Created by Nick Kaczmarek on 3/16/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent
import SwiftCurrent_SwiftUI

struct Registry: FlowRepresentableAggregator {
    public init() { types = [] }

    public var types: [WorkflowDecodable.Type]

    public init(types: [WorkflowDecodable.Type]) {
        self.types = types
    }
}

@MainActor
class WorkflowViewModel: ObservableObject {
    @Published var workflow: AnyWorkflow? = nil
    @Published var isFetching: Bool = false
    let registry = Registry(types: [ContentView.self, AnotherView.self, ThirdView.self])

    init() {
        fetchDefaultWorkflowFromDisk()
    }

    func fetchDefaultWorkflowFromDisk() {
        let workflowJson = Bundle.main.path(forResource: "spec", ofType: "json")
        let specString = try! String(contentsOfFile: workflowJson!)
        let specData = specString.data(using: .utf8)
        workflow = try! JSONDecoder().decodeWorkflow(withAggregator: registry, from: specData!)
    }

    func fetchWorkflowFromServer() async throws {
        isFetching = true

        if let specURL = URL(string: "https://wwt.github.io/SwiftCurrent/dataDrivenWorkflowSpec.json") {
            let (workflowJson, _) = try await URLSession.shared.data(from: specURL)
            workflow = try JSONDecoder().decodeWorkflow(withAggregator: registry, from: workflowJson)
        }

        isFetching = false
    }

}

struct OnboardingView: View {
    @ObservedObject var viewModel: WorkflowViewModel

    init() {
        viewModel = WorkflowViewModel()
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("Wilkommen")
                if viewModel.isFetching {
                    ProgressView()
                        .tint(Color.accentColor)
                } else if let workflow = viewModel.workflow {
                    NavigationLink("Go there") {
                        WorkflowLauncher(isLaunched: .constant(true), workflow: workflow)
                    }
                } else {
                    Text("Not able to load workflow from file or server")
                }
            }
        }
        .task {
            try? await viewModel.fetchWorkflowFromServer()
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
