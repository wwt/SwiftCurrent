//
//  MFAuthenticationView.swift
//  SwiftUIExampleApp
//
//  Created by Tyler Thompson on 7/15/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import SwiftUI
import SwiftCurrent

struct MFAView: View, FlowRepresentable {
    typealias WorkflowOutput = AnyWorkflow.PassedArgs

    @State var pushSent = false
    @State var enteredCode = ""
    @State var errorMessage: ErrorMessage?

    let inspection = Inspection<Self>()
    weak var _workflowPointer: AnyFlowRepresentable?

    private let heldWorkflowData: AnyWorkflow.PassedArgs
    init(with data: AnyWorkflow.PassedArgs) {
        heldWorkflowData = data
    }

    var body: some View {
        VStack(spacing: 30) {
            if !pushSent {
                Text("This is your friendly MFA Assistant! Tap the button below to pretend to send a push notification and require an account code")
                Button {
                    pushSent = true
                } label: {
                    Text("Start MFA")
                        .font(.title)
                        .foregroundColor(Color.white)
                        .padding()
                }
                .background(Color.blue)
            } else {
                Text("Code (enter 1234 to proceed): ").font(.title)
                TextField("Enter Code:", text: $enteredCode)
                Button("Submit") {
                    if enteredCode == "1234" {
                        proceedInWorkflow(heldWorkflowData)
                    } else {
                        errorMessage = ErrorMessage(message: "Invalid code entered, abandoning workflow.")
                    }
                }
            }
        }
        .padding()
        .testableAlert(item: $errorMessage) { message in
            Alert(title: Text(message.message), dismissButton: .default(Text("Ok")) {
                workflow?.abandon()
            })
        }
        .onReceive(inspection.notice) { inspection.visit(self, $0) }
    }
}

extension MFAView {
    struct ErrorMessage: Identifiable {
        let id = UUID()
        let message: String
    }
}

struct MFAuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        MFAView(with: .none)
    }
}
