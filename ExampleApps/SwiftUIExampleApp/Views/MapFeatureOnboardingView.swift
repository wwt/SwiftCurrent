//
//  MapFeatureOnboardingView.swift
//  SwiftUIExampleApp
//
//  Created by Tyler Thompson on 7/14/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import Foundation
import SwiftUI

import SwiftCurrent

struct MapFeatureOnboardingView: View, FlowRepresentable {
    @DependencyInjected private static var userDefaults: UserDefaults!

    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        Text("Learn about our awesome map feature!")
        Button("Continue") {
            Self.userDefaults.set(true, forKey: "OnboardedToMapFeature")
            proceedInWorkflow()
        }
    }

    func shouldLoad() -> Bool {
        !Self.userDefaults.bool(forKey: "OnboardedToMapFeature")
    }
}
