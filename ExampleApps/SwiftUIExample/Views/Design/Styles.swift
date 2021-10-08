//  swiftlint:disable:this file_name
//  Styles.swift
//  Styles
//
//  Created by Richard Gist on 8/25/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import SwiftUI

extension Text {
    func titleStyle() -> Text {
        foregroundColor(.primaryText)
            .font(.title)
            .fontWeight(.bold)
    }

    func primaryButtonStyle() -> some View {
        foregroundColor(.white)
            .fontWeight(.bold)
            .padding(.vertical)
            .padding(.horizontal, 50)
            .background(Color.primaryButton)
            .clipShape(Capsule())
            .shadow(color: .white.opacity(0.1), radius: 5, x: 0, y: 5)
    }

    func secondaryButtonStyle() -> some View {
        foregroundColor(.white)
            .fontWeight(.bold)
            .shadow(color: .white.opacity(0.1), radius: 5, x: 0, y: 5)
            .padding(.vertical)
            .padding(.horizontal, 50)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.primaryButton, lineWidth: 4))
            .shadow(color: .white.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

extension View {
    func textEntryStyle() -> some View {
        padding(.horizontal, 10)
            .padding(.vertical, 15)
            .background(EmptyView().background().opacity(0.5))
            .clipShape(Capsule())
    }
}

extension Image {
    func iconStyle() -> some View {
        resizable()
        .scaledToFit()
        .frame(width: 20, height: 20)
    }
}
