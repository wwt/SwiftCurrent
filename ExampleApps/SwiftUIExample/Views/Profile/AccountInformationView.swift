//
//  UpdatedAccountInformationView.swift
//  SwiftUIExample
//
//  Created by Tyler Thompson on 7/15/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import SwiftUI
import SwiftCurrent_SwiftUI

struct AccountInformationView: View {
    @State var password = "supersecure"
    @State var email = "SwiftCurrent@wwt.com"
    @State var emailWorkflowLaunched = false
    @State var passwordWorkflowLaunched = false

    let inspection = Inspection<Self>() // ViewInspector

    var body: some View {
        VStack(alignment: .leading, spacing: 25) { // swiftlint:disable:this closure_body_length
            // IMPORTANT THAT THIS ONLY SHOWS WHEN NOT UPDATING
            if !emailWorkflowLaunched {
                HStack(spacing: 15) {
                    Image.account
                        .iconStyle()
                        .foregroundColor(.icon)
                    Text("Email: ")
                    Text(email)
                    Spacer()
                    Button {
                        withAnimation {
                            emailWorkflowLaunched = true
                        }
                    } label: {
                        Image(systemName: "pencil")
                            .iconStyle()
                            .foregroundColor(.icon)
                    }
                }
                .textEntryStyle()
            } else {
                WorkflowView(isLaunched: $emailWorkflowLaunched.animation(), launchingWith: email) {
                    WorkflowItem { MFAView() }
                    WorkflowItem { (args: String) in ChangeEmailView(with: args) }
                }.onFinish {
                    guard case .args(let newEmail as String) = $0 else { return }
                    email = newEmail
                    withAnimation {
                        emailWorkflowLaunched = false
                    }
                }
            }

            if !passwordWorkflowLaunched {
                HStack(spacing: 15) {
                    Image.password
                        .iconStyle()
                        .foregroundColor(.icon)
                    Text("Password: ")
                    SecureField(text: $password) { EmptyView() }.disabled(true)
                    Spacer()
                    Button {
                        withAnimation {
                            passwordWorkflowLaunched = true
                        }
                    } label: {
                        Image(systemName: "pencil")
                            .iconStyle()
                            .foregroundColor(.icon)
                    }
                }
                .textEntryStyle()
            } else {
                WorkflowView(isLaunched: $passwordWorkflowLaunched.animation(), launchingWith: password) {
                    WorkflowItem { MFAView() }
                    WorkflowItem { (args: String) in
                        NavigationStack {
                            VStack {
                                ChangePasswordView(with: args)
                                    .padding()
                                    .background(Color.card)
                                    .cornerRadius(35)
                                    .padding(.horizontal, 20)
                                    .navigationTitle("Update password")

                                Spacer()
                            }
                        }
                    }
                    .presentationType(.modal)
                }.onFinish {
                    guard case .args(let newPassword as String) = $0 else { return }
                    password = newPassword
                    passwordWorkflowLaunched = false
                }
            }
        }.onReceive(inspection.notice) { inspection.visit(self, $0) } // ViewInspector
    }
}

struct UpdatedAccountInformationView_Previews: PreviewProvider {
    static var previews: some View {
        AccountInformationView()
            .preferredColorScheme(.dark)
            .background(Color.primaryBackground)
    }
}
