//
//  ContentView.swift
//  SwiftUIExampleApp
//
//  Created by Tyler Thompson on 7/14/21.
//

import SwiftUI
import SwiftCurrent_SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // NOTE: Using constant here guarantees the workflow cannot abandon, it stays launched forever.
            WorkflowView(isPresented: .constant(true))
                .thenProceed(with: WorkflowItem(MapFeatureOnboardingView.self))
                .thenProceed(with: WorkflowItem(MapFeatureView.self))
                .tabItem {
                    Label("Map Feature", systemImage: "map")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
