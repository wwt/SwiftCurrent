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
        Color(red: 86 / 255, green: 86 / 255, blue: 118 / 255)
            .opacity(0.8)
    }

    static var icon: Color {
        primaryColor
    }

    static var primaryButton: Color {
        primaryColor
    }

    private static var primaryColor: Color {
        Color(red: 0 / 255, green: 134 / 255, blue: 234 / 255)
    }

    static var divider: Color {
        white.opacity(0.5)
    }
}
