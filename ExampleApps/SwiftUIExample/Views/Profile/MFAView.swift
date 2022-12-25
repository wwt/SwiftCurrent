//
//  MFAView.swift
//  SwiftUIExample
//
//  Created by Tyler Thompson on 7/15/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import SwiftUI
import SwiftCurrent_SwiftUI

struct MFAView: View {
    @State var pushSent = false
    @State var enteredCode = ""
    @State var errorMessage: ErrorMessage?
    @State private var id = UUID()
    @State private var shouldProceed = false

    let inspection = Inspection<Self>() // ViewInspector

    var body: some View {
        VStack(spacing: 30) {
            if !pushSent {
                Text("This is your friendly MFA Assistant! Tap the button below to pretend to send a push notification and require an account code")
                PrimaryButton(title: "Start MFA") {
                    withAnimation { pushSent = true }
                }
            } else {
                Text("Code (enter 1234 to proceed)").font(.title)

                PrimaryTextField(label: "Code", placeholder: "Enter Code", image: Image(systemName: "number"), text: $enteredCode)

                PrimaryButton(title: "Submit") {
                    if enteredCode == "1234" {
                        withAnimation {
                            shouldProceed = true
                        }
                    } else {
                        errorMessage = ErrorMessage(message: "Invalid code entered, abandoning workflow.")
                    }
                }
            }
        }
        .padding()
        .testableAlert(item: $errorMessage) { message in
            Alert(title: Text(message.message), dismissButton: .default(Text("Ok")) {
                withAnimation {
                    #warning("Abandon not a thing")
                }
            })
        }
        .animation(.easeInOut, value: true)
        .transition(.opacity)
        .workflowLink(isPresented: $shouldProceed)
        .onReceive(inspection.notice) { inspection.visit(self, $0) } // ViewInspector
    }
}

extension MFAView {
    struct ErrorMessage: Identifiable {
        let id = UUID()
        let message: String
    }
}

struct MFAView_Previews: PreviewProvider {
    static var previews: some View {
        MFAView()
            .preferredColorScheme(.dark)
    }
}
