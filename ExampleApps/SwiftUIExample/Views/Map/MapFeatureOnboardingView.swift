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
import SwiftCurrent_SwiftUI

struct MapFeatureOnboardingView: View {
    @AppStorage("OnboardedToMapFeature", store: .fromDI) private var onboardedToMapFeature = false
    @State var shouldProceed = false

    let inspection = Inspection<Self>() // ViewInspector

    var body: some View {
        VStack {
            Text("Learn about our awesome map feature!")
            Button("Continue") {
                onboardedToMapFeature = true
                shouldProceed = true
            }
        }
        .workflowLink(isPresented: $shouldProceed)
        .shouldLoad(!onboardedToMapFeature)
        .onReceive(inspection.notice) { inspection.visit(self, $0) } // ViewInspector
    }
}
