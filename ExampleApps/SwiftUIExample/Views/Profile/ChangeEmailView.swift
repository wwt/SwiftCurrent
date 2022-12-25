//
//  ChangeEmailView.swift
//  SwiftUIExample
//
//  Created by Tyler Thompson on 7/15/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import SwiftUI
import SwiftCurrent_SwiftUI

struct ChangeEmailView: View {
    @State private var currentEmail: String
    @State private var shouldProceed = false

    let inspection = Inspection<Self>() // ViewInspector

    init(with email: String) {
        _currentEmail = State(initialValue: email)
    }

    var body: some View {
        VStack {
            PrimaryTextField(label: "New email", placeholder: currentEmail, image: Image.account, text: $currentEmail)
                .padding(.bottom)

            PrimaryButton(title: "SAVE") {
                withAnimation {
                    shouldProceed = true
                }
            }
        }
        .workflowLink(isPresented: $shouldProceed, value: currentEmail)
        .onReceive(inspection.notice) { inspection.visit(self, $0) } // ViewInspector
    }
}

struct UpdatedChangeEmailView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeEmailView(with: "Email input")
            .preferredColorScheme(.dark)
            .background(Color.primaryBackground)
    }
}
