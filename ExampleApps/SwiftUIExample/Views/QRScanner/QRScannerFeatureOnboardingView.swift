//
//  QRScannerFeatureOnboardingView.swift
//  SwiftUIExample
//
//  Created by Tyler Thompson on 7/14/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import SwiftUI
import SwiftCurrent_SwiftUI
import Swinject

struct QRScannerFeatureOnboardingView: View {
    @AppStorage("OnboardedToQRScanningFeature", store: .fromDI) private var onboardedToQRScanningFeature = false
    @State private var shouldProceed = false

    let inspection = Inspection<Self>() // ViewInspector

    var body: some View {
        VStack {
            Text("Learn about our awesome QR scanning feature!")
            Button("Continue") {
                onboardedToQRScanningFeature = true
                shouldProceed = true
            }
        }
        .workflowLink(isPresented: $shouldProceed)
        .shouldLoad(!onboardedToQRScanningFeature)
        .onReceive(inspection.notice) { inspection.visit(self, $0) } // ViewInspector
    }
}
