//
//  PrimaryButton.swift
//  PrimaryButton
//
//  Created by Tyler Thompson on 8/30/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .primaryButtonStyle()
        }
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryButton(title: "test") { }
            .preferredColorScheme(.dark)
    }
}
