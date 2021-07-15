//
//  ProfileFeatureOnboardingView.swift
//  SwiftUIExampleApp
//
//  Created by Tyler Thompson on 7/15/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import SwiftUI
import SwiftCurrent

struct ProfileFeatureOnboardingView: View, FlowRepresentable {
    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        Text("Learn about our awesome profile feature!")
        Button("Continue") {
            UserDefaults.standard.set(true, forKey: "OnboardedToQRProfileFeature")
            proceedInWorkflow()
        }
    }

    func shouldLoad() -> Bool {
        !UserDefaults.standard.bool(forKey: "OnboardedToQRProfileFeature")
    }
}
