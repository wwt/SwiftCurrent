//
//  ProfileFeatureOnboardingView.swift
//  SwiftUIExample
//
//  Created by Tyler Thompson on 7/15/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import SwiftUI
import SwiftCurrent
import Swinject
import SwiftCurrent_SwiftUI

struct ProfileFeatureOnboardingView: View, PassthroughFlowRepresentable {
    let inspection = Inspection<Self>() // ViewInspector
    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        onboardingView
            .onReceive(inspection.notice) { inspection.visit(self, $0) } // ViewInspector
    }

    private var onboardingView: GenericOnboardingView {
        GenericOnboardingView(model: .profileFeature) {
            proceedInWorkflow()
        }
    }

    func shouldLoad() -> Bool {
        onboardingView.shouldLoad()
    }
}

extension OnboardingData {
    fileprivate static let profileFeature = OnboardingData(previewImage: .profileOnboarding,
                                                           previewAccent: .icon,
                                                           featureTitle: "Welcome to our new profile management feature!",
                                                           featureSummary: "You can update your username and password here.",
                                                           appStorageKey: "OnboardedToProfileFeature",
                                                           appStorageStore: .fromDI)
}
