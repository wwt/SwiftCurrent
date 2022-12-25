//
//  LoginView.swift
//  LoginView
//
//  Created by Richard Gist on 8/25/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  swiftlint:disable closure_body_length

import SwiftUI
import SwiftCurrent
import SwiftCurrent_SwiftUI

struct LoginView: View, FlowRepresentable {
    let inspection = Inspection<Self>() // ViewInspector
    weak var _workflowPointer: AnyFlowRepresentable?
    @State var email = ""
    @State var password = ""
    @State var showSignUp = false
    @State var isLoggedIn = false

    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 40) {
                Image.logo
                    .resizable()
                    .shadow(color: .white.opacity(0.1), radius: 5, x: 0, y: 5)
                    .frame(width: 120, height: 120)
                    .foregroundColor(.icon)

                ZStack(alignment: .bottom) {
                    VStack {
                        Text("Welcome!")
                            .titleStyle()

                        VStack(spacing: 15) {
                            PrimaryTextField(placeholder: "Email Address", image: Image.account, text: $email)
                                .keyboardType(.emailAddress)

                            PasswordField(password: $password)
                        }
                        .padding(.bottom, 8)
                    }
                    .padding()
                    .padding(.bottom, 25)
                    .background(Color.card)
                    .cornerRadius(35)
                    .padding(.horizontal, 20)

                    PrimaryButton(title: "LOGIN", action: proceedInWorkflow)
                        .offset(y: 25)
                }
                .padding(.bottom, 27)

                HStack(spacing: 15) {
                    Rectangle()
                        .fill(Color.divider)
                        .frame(height: 1)

                    Text("OR")
                        .foregroundColor(Color.white.opacity(0.8))

                    Rectangle()
                        .fill(Color.divider)
                        .frame(height: 1)
                }
                .padding(.horizontal)

                SecondaryButton(title: "Sign Up") {
                    showSignUp = true
                }
            }
        }
        .background(Color.primaryBackground.edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showSignUp) {
            NavigationStack {
                WorkflowView(isLaunched: $showSignUp) {
                    WorkflowItem { SignUp() }
                        .presentationType(.navigationLink)
                    WorkflowItem { TermsAndConditions() }
                        .presentationType(.navigationLink)
                }
                .onFinish { _ in
                    showSignUp = false
                    proceedInWorkflow() // untested
                }
            }
        }
        .onReceive(inspection.notice) { inspection.visit(self, $0) } // ViewInspector
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView().preferredColorScheme(.dark)
        }
    }
}
