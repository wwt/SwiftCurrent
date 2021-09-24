//
//  ProfileFeatureView.swift
//  SwiftUIExample
//
//  Created by Tyler Thompson on 7/15/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import SwiftUI
import SwiftCurrent

struct ProfileFeatureView: View, FlowRepresentable {
    let inspection = Inspection<Self>() // ViewInspector
    @DependencyInjected private static var userDefaults: UserDefaults!
    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        VStack {
            Image.wwtLogo
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(35)
                .background(
                    Circle().stroke(Color.icon, lineWidth: 4)
                        .shadow(color: .icon, radius: 7)
                )
                .padding()
                .frame(width: 300, height: 300)
                .onTapGesture(count: 5, perform: clearUserDefaults)
            ScrollView {
                    Divider()
                    Section(header: Text("Account Information").font(.title)) {
                        AccountInformationView().padding()
                    }
                    Spacer()
            }
            .background(Color.card)
        }
        .background(Color.primaryBackground)
        .onReceive(inspection.notice) { inspection.visit(self, $0) } // ViewInspector
    }

    private func clearUserDefaults() {
        Self.userDefaults.dictionaryRepresentation().keys.forEach(Self.userDefaults.removeObject(forKey:))
        print("Defaults cleared")
    }
}

struct UpdatedProfileFeature_Previews: PreviewProvider {
    static var previews: some View {
        ProfileFeatureView().preferredColorScheme(.dark)
    }
}
