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
    @State var password = "supersecure"
    @State var usernameWorkflowLaunched = false
    @State var passwordWorkflowLaunched = false
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
        if !passwordWorkflowLaunched {
            Button("Change Password") {
                passwordWorkflowLaunched = true
            }
        } else {
            WorkflowView(isPresented: $passwordWorkflowLaunched, args: password)
                .thenProceed(with: WorkflowItem(MFAuthenticationView.self))
                .thenProceed(with: WorkflowItem(ChangePasswordView.self))
                .onFinish {
                    guard case .args(let newPassword as String) = $0 else { return }
                    password = newPassword
                    passwordWorkflowLaunched = false
                }
        }
    }
}
