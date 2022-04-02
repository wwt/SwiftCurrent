//
//  PrimaryTextField.swift
//  PrimaryTextField
//
//  Created by Tyler Thompson on 8/30/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI

struct PrimaryTextField: View {
    let inspection = Inspection<Self>() // ViewInspector

    @State var label: String?
    @State var placeholder = "Password"

    let image: Image
    @Binding var text: String

    var body: some View {
        HStack(spacing: 15) {
            image
                .iconStyle()
                .foregroundColor(.icon)
            if let label = label {
                Text("\(label): ")
            }
            TextField(placeholder, text: $text)
            Spacer()
        }
        .textEntryStyle()
        .onReceive(inspection.notice) { inspection.visit(self, $0) } // ViewInspector
    }
}

struct PrimaryTextField_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryTextField(label: "test", image: Image(systemName: "circle"), text: .constant("some value"))
            .preferredColorScheme(.dark)
    }
}
