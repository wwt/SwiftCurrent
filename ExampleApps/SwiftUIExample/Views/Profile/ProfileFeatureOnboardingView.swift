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

struct ProfileFeatureOnboardingView: View, FlowRepresentable {
    @AppStorage("OnboardedToProfileFeature", store: .fromDI) private var onboardedToProfileFeature = false

    let inspection = Inspection<Self>() // ViewInspector
    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        VStack {
            Text("Learn about our awesome profile feature!")
            Button("Continue") {
                onboardedToProfileFeature = true
                proceedInWorkflow()
            }
        }.onReceive(inspection.notice) { inspection.visit(self, $0) } // ViewInspector
    }

    func shouldLoad() -> Bool {
        !onboardedToProfileFeature
    }
}
