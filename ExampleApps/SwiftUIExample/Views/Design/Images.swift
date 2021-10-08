//  swiftlint:disable:this file_name
//  Images.swift
//  Images
//
//  Created by Richard Gist on 8/25/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import SwiftUI

extension Image {
    static var logo: Image {
        Image("swiftcurrent-logo")
    }

    static var account: Image {
        Image(systemName: "envelope.fill")
    }

    static var password: Image {
        Image(systemName: "lock.fill")
    }

    static var socialMediaIcon: Image {
        Image("swiftcurrent-logo-subtext")
    }

    static var profileOnboarding: Image {
        Image("profile-screenshot")
    }

    static var wwtLogo: Image {
        Image("wwt-logo")
    }
}
