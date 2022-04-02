//
//  OnboardingData.swift
//  SwiftCurrent
//
//  Created by Richard Gist on 10/6/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI

struct OnboardingData {
    let previewImage: Image
    let previewAccent: Color
    let featureTitle: String
    let featureSummary: String
    let appStorageKey: String
    let appStorageStore: UserDefaults?

    static let mapFeature = OnboardingData(previewImage: .logo,
                                           previewAccent: .icon,
                                           featureTitle: "Maps!",
                                           featureSummary: "We've got all kinds of maps like this one.",
                                           appStorageKey: "MapOnboardingFeature",
                                           appStorageStore: .fromDI)
}
