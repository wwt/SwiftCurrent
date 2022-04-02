//
//  PasswordField.swift
//  PasswordField
//
//  Created by Tyler Thompson on 8/30/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI

struct PasswordField: View {
    @Binding var password: String
    @State private var showPassword: Bool

    let inspection = Inspection<Self>() // ViewInspector
    private let placeholder: String

    init(placeholder: String = "Password", showPassword: Bool = false, password: Binding<String>) {
        self.placeholder = placeholder
        self.showPassword = showPassword
        self._password = password
    }

    var body: some View {
        HStack(spacing: 15) {
            Button {
                showPassword.toggle()
            } label: {
                Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                    .iconStyle()
                    .foregroundColor(.icon)
            }
            if showPassword {
                TextField(placeholder, text: $password)
                    .disableAutocorrection(true)
            } else {
                SecureField(placeholder, text: $password)
                    .disableAutocorrection(true)
            }
        }
        .textEntryStyle()
        .onReceive(inspection.notice) { inspection.visit(self, $0) } // ViewInspector
    }
}

struct PasswordField_Previews: PreviewProvider {
    static var previews: some View {
        PasswordField(showPassword: false, password: .constant("TEST"))
            .preferredColorScheme(.dark)
    }
}
