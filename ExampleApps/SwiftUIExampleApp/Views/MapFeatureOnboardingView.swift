//
//  MapFeatureOnboardingView.swift
//  SwiftUIExampleApp
//
//  Created by Tyler Thompson on 7/14/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import Foundation
import SwiftUI
import Swinject

import SwiftCurrent

struct MapFeatureOnboardingView: View, FlowRepresentable {
    private var userDefaults: UserDefaults! { Container.default.resolve(UserDefaults.self) }

    let inspection = Inspection<Self>()
    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        Group {
            Text("Learn about our awesome map feature!")
            Button("Continue") {
                userDefaults.set(true, forKey: "OnboardedToMapFeature")
                proceedInWorkflow()
            }
        }.onReceive(inspection.notice) { inspection.visit(self, $0) }
    }

    func shouldLoad() -> Bool {
        !userDefaults.bool(forKey: "OnboardedToMapFeature")
    }
}
