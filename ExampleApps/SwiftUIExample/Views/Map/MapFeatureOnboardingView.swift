//
//  MapFeatureOnboardingView.swift
//  SwiftUIExample
//
//  Created by Tyler Thompson on 7/14/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import Foundation
import SwiftUI
import Swinject

import SwiftCurrent

struct MapFeatureOnboardingView: View, FlowRepresentable {
    @AppStorage("OnboardedToMapFeature", store: .fromDI) private var onboardedToMapFeature = false

    let inspection = Inspection<Self>() // ViewInspector
    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        VStack {
            Text("Learn about our awesome map feature!")
            Button("Continue") {
                onboardedToMapFeature = true
                proceedInWorkflow()
            }
        }.onReceive(inspection.notice) { inspection.visit(self, $0) } // ViewInspector
    }

    func shouldLoad() -> Bool {
        !onboardedToMapFeature
    }
}
