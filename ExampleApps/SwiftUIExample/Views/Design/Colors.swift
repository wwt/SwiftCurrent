//  swiftlint:disable:this file_name
//  Colors.swift
//  Colors
//
//  Created by Richard Gist on 8/25/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import SwiftUI

extension Color {
    static var primaryBackground: Color {
        .black
    }

    static var primaryText: Color {
        white
    }

    static var card: Color {
        Color(rgbRed: 86, rgbGreen: 86, rgbBlue: 255)
            .opacity(0.8)
    }

    static var icon: Color {
        primaryColor
    }

    static var primaryButton: Color {
        primaryColor
    }

    private static var primaryColor: Color {
        Color(rgbRed: 0, rgbGreen: 134, rgbBlue: 234)
    }

    static var divider: Color {
        white.opacity(0.5)
    }

    /// Creates a `Color` using RGB values.
    init(rgbRed: UInt8, rgbGreen: UInt8, rgbBlue: UInt8) {
        self.init(red: Double(rgbRed) / 255, green: Double(rgbGreen) / 255, blue: Double(rgbBlue) / 255)
    }
}
