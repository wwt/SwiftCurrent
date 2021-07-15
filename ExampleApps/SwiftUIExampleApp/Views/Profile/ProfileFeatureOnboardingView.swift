//
//  ProfileFeatureOnboardingView.swift
//  SwiftUIExampleApp
//
//  Created by Tyler Thompson on 7/15/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import SwiftUI
import SwiftCurrent
import Swinject

struct ProfileFeatureOnboardingView: View, FlowRepresentable {
    private var userDefaults: UserDefaults! { Container.default.resolve(UserDefaults.self) }

    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        Text("Learn about our awesome profile feature!")
        Button("Continue") {
            userDefaults.set(true, forKey: "OnboardedToProfileFeature")
            proceedInWorkflow()
        }
    }

    func shouldLoad() -> Bool {
        !userDefaults.bool(forKey: "OnboardedToProfileFeature")
    }
}