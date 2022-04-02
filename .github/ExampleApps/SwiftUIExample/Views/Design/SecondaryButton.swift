//
//  SecondaryButton.swift
//  SecondaryButton
//
//  Created by Tyler Thompson on 8/30/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI

struct SecondaryButton: View {
    let inspection = Inspection<Self>() // ViewInspector
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .secondaryButtonStyle()
        }.onReceive(inspection.notice) { inspection.visit(self, $0) } // ViewInspector
    }
}

struct SecondaryButton_Previews: PreviewProvider {
    static var previews: some View {
        SecondaryButton(title: "test") { }
            .preferredColorScheme(.dark)
    }
}
