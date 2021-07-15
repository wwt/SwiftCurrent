//
//  ContentView.swift
//  SwiftUIExampleApp
//
//  Created by Tyler Thompson on 7/14/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import SwiftUI
import SwiftCurrent_SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // NOTE: Using constant here guarantees the workflow cannot abandon, it stays launched forever.
            WorkflowView(isLaunched: .constant(true))
                .thenProceed(with: WorkflowItem(MapFeatureOnboardingView.self))
                .thenProceed(with: WorkflowItem(MapFeatureView.self))
                .tabItem {
                    Label("Map", systemImage: "map")
                }

            WorkflowView(isLaunched: .constant(true))
                .thenProceed(with: WorkflowItem(QRScannerFeatureOnboardingView.self))
                .thenProceed(with: WorkflowItem(QRScannerFeatureView.self))
                .tabItem {
                    Label("QR Scanner", systemImage: "camera")
                }

            WorkflowView(isLaunched: .constant(true))
                .thenProceed(with: WorkflowItem(ProfileFeatureOnboardingView.self))
                .thenProceed(with: WorkflowItem(ProfileFeatureView.self))
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
