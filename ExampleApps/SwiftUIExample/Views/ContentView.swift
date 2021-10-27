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
    }
    @State var selectedTab: Tab = .map
    weak var _workflowPointer: AnyFlowRepresentable?
    var body: some View {
        TabView(selection: $selectedTab) {
            // NOTE: Using constant here guarantees the workflow cannot abandon, it stays launched forever.
            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: MapFeatureOnboardingView.self) {
                    thenProceed(with: MapFeatureView.self)
                }
            }.tabItem {
                Label("Map", systemImage: "map")
            }
            .tag(Tab.map)

            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: QRScannerFeatureOnboardingView.self) {
                    thenProceed(with: QRScannerFeatureView.self)
                }
            }.tabItem {
                Label("QR Scanner", systemImage: "camera")
            }
            .tag(Tab.qr)

            WorkflowLauncher(isLaunched: .constant(true)) {
                thenProceed(with: ProfileFeatureOnboardingView.self) {
                    thenProceed(with: ProfileFeatureView.self)
                }
            }.tabItem {
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
