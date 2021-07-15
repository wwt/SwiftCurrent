//
//  QRScannerFeatureOnboardingView.swift
//  SwiftUIExampleApp
//
//  Created by Tyler Thompson on 7/14/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import SwiftUI
import SwiftCurrent

struct QRScannerFeatureOnboardingView: View, FlowRepresentable {
    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        Text("Learn about our awesome QR scanning feature!")
        Button("Continue") {
            proceedInWorkflow()
        }
    }

    func shouldLoad() -> Bool {
        !UserDefaults.standard.bool(forKey: "OnboardedToQRScanningFeature")
    }
}
