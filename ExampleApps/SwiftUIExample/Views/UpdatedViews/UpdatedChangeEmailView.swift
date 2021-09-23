//
//  UpdatedChangeEmailView.swift
//  SwiftUIExample
//
//  Created by Tyler Thompson on 7/15/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import SwiftUI
import SwiftCurrent

struct UpdatedChangeEmailView: View, FlowRepresentable {
    typealias WorkflowOutput = String

    @State private var currentEmail: String

    let inspection = Inspection<Self>() // ViewInspector
    weak var _workflowPointer: AnyFlowRepresentable?

    init(with email: String) {
        _currentEmail = State(initialValue: email)
    }

    var body: some View {
        VStack {
            PrimaryTextField(label: "New email", placeholder: currentEmail, image: Image.account, text: $currentEmail)
                .padding(.bottom)

            PrimaryButton(title: "SAVE") {
                withAnimation {
                    proceedInWorkflow(currentEmail)
                }
            }
        }
        .onReceive(inspection.notice) { inspection.visit(self, $0) } // ViewInspector
    }
}

struct UpdatedChangeEmailView_Previews: PreviewProvider {
    static var previews: some View {
        UpdatedChangeEmailView(with: "Email input")
            .preferredColorScheme(.dark)
            .background(Color.primaryBackground)
    }
}
