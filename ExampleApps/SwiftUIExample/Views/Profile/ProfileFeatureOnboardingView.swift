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
    @AppStorage(OnboardingModel.profileFeature.appStorageKey, store: .fromDI) private var onboardedToProfileFeature = false

    let inspection = Inspection<Self>() // ViewInspector
    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        WorkflowLauncher(isLaunched: .constant(true), startingArgs: .profileFeature) {
            thenProceed(with: GenericOnboardingView.self)
        } .onFinish { _ in
            proceedInWorkflow()
        }
        .onReceive(inspection.notice) { inspection.visit(self, $0) } // ViewInspector
    }

    func shouldLoad() -> Bool {
        !onboardedToProfileFeature
    }
}
