//
//  SignUp.swift
//  SignUp
//
//  Created by Tyler Thompson on 8/25/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI
import SwiftCurrent

struct SignUp: View, FlowRepresentable {
    let inspection = Inspection<Self>() // ViewInspector
    weak var _workflowPointer: AnyFlowRepresentable?
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 20) {
                Text("We just need a little bit of information to get you started.")
                    .multilineTextAlignment(.center)

                VStack(spacing: 15) {
                    PrimaryTextField(placeholder: "Email Address", image: Image.account, text: $email)
                        .keyboardType(.emailAddress)

                    PasswordField(password: $password)

                    PasswordField(placeholder: "Confirm Password", password: $confirmPassword)
                }

                HStack {
                    Spacer(minLength: 0)
                }

                PrimaryButton(title: "Next", action: proceedInWorkflow)
            }
            .padding()
            .padding(.bottom, 5)
            .padding(.horizontal, 20)
            .background(Color.card)
            .cornerRadius(50)
            .padding(.top, 30)
        }
        .background(Color.primaryBackground.edgesIgnoringSafeArea(.all))
        .navigationTitle("Sign Up!")
        .onReceive(inspection.notice) { inspection.visit(self, $0) } // ViewInspector
    }
}

struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignUp().preferredColorScheme(.dark)
        }
    }
}
