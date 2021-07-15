//
//  AccountInformationView.swift
//  SwiftUIExampleApp
//
//  Created by Tyler Thompson on 7/15/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import SwiftUI
import SwiftCurrent
import SwiftCurrent_SwiftUI

struct AccountInformationView: View, FlowRepresentable {
    @State var username = "changeme"
    @State var usernameWorkflowLaunched = false
    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        if !usernameWorkflowLaunched {
            HStack {
                Text("Username: \(username)")
                Spacer()
                Button("Change Username") {
                    usernameWorkflowLaunched = true
                }
            }
        } else {
            WorkflowView(isPresented: $usernameWorkflowLaunched, args: username)
                .thenProceed(with: WorkflowItem(MFAuthenticationView.self))
                .thenProceed(with: WorkflowItem(ChangeUsernameView.self))
                .onFinish {
                    guard case .args(let newUsername as String) = $0 else { return }
                    username = newUsername
                    usernameWorkflowLaunched = false
                }
        }
        Text("Password: ")
    }
}

struct ChangeUsernameView: View, FlowRepresentable {
    typealias WorkflowOutput = String

    @State private var currentUsername: String

    weak var _workflowPointer: AnyFlowRepresentable?

    init(with username: String) {
        _currentUsername = State(initialValue: username)
    }

    var body: some View {
        VStack {
            HStack {
                Text("Enter new username: ")
                TextField("\(currentUsername)", text: $currentUsername)
            }
            Button("Save") {
                proceedInWorkflow(currentUsername)
            }
        }
    }
}
