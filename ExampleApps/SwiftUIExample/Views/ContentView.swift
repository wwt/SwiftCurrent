//
//  ContentView.swift
//  SwiftUIExample
//
//  Created by Tyler Thompson on 7/14/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import SwiftUI
import SwiftCurrent_SwiftUI

struct ContentView: View {
    let inspection = Inspection<Self>() // ViewInspector
    enum Tab {
        case map
        case qr
        case profile
    }
    @State var selectedTab: Tab = .map
    var body: some View {
        TabView(selection: $selectedTab) {
            // NOTE: Using constant here guarantees the workflow cannot abandon, it stays launched forever.
            WorkflowLauncher(isLaunched: .constant(true))
                .thenProceed(with: WorkflowItem(MapFeatureOnboardingView.self))
                .thenProceed(with: WorkflowItem(MapFeatureView.self))
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(Tab.map)

            WorkflowLauncher(isLaunched: .constant(true))
                .thenProceed(with: WorkflowItem(QRScannerFeatureOnboardingView.self))
                .thenProceed(with: WorkflowItem(QRScannerFeatureView.self))
                .tabItem {
                    Label("QR Scanner", systemImage: "camera")
                }
                .tag(Tab.qr)

            WorkflowLauncher(isLaunched: .constant(true))
                .thenProceed(with: WorkflowItem(ProfileFeatureOnboardingView.self))
                .thenProceed(with: WorkflowItem(ProfileFeatureView.self))
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(Tab.profile)
        }
        .onReceive(inspection.notice) { inspection.visit(self, $0) } // ViewInspector
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
