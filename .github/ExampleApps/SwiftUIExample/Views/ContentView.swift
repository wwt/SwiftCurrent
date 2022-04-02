//
//  ContentView.swift
//  SwiftUIExample
//
//  Created by Tyler Thompson on 7/14/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import SwiftUI
import SwiftCurrent
import SwiftCurrent_SwiftUI

struct ContentView: View, FlowRepresentable {
    let inspection = Inspection<Self>() // ViewInspector
    enum Tab {
        case map
        case qr
        case profile
        case settings
    }
    @State var selectedTab: Tab = .map
    weak var _workflowPointer: AnyFlowRepresentable?
    var body: some View {
        TabView(selection: $selectedTab) { // swiftlint:disable:this closure_body_length
            // NOTE: Using constant here guarantees the workflow cannot abandon, it stays launched forever.
            WorkflowView {
                WorkflowItem(MapFeatureOnboardingView.self)
                WorkflowItem(MapFeatureView.self)
            }.tabItem {
                Label("Map", systemImage: "map")
            }
            .tag(Tab.map)

            WorkflowView {
                WorkflowItem(QRScannerFeatureOnboardingView.self)
                WorkflowItem(QRScannerFeatureView.self)
            }.tabItem {
                Label("QR Scanner", systemImage: "camera")
            }
            .tag(Tab.qr)

            WorkflowView {
                WorkflowItem(ProfileFeatureOnboardingView.self)
                WorkflowItem(ProfileFeatureView.self)
            }.tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
            .tag(Tab.profile)

            WorkflowView {
                WorkflowItem(SettingsOnboardingViewController.self)
                WorkflowItem(SettingsViewController.self)
            }.tabItem {
                Label("Settings", systemImage: "gear.circle.fill")
            }
            .tag(Tab.settings)
        }
        .onReceive(inspection.notice) { inspection.visit(self, $0) } // ViewInspector
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
