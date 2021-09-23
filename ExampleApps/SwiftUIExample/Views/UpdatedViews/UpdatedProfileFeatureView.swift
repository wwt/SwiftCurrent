//
//  UpdatedProfileFeatureView.swift
//  SwiftUIExample
//
//  Created by Tyler Thompson on 7/15/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import SwiftUI
import SwiftCurrent

struct UpdatedProfileFeatureView: View, FlowRepresentable {
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
            ScrollView {
                    Divider()

                    Section(header: Text("Account Information").font(.title)) {
                        UpdatedAccountInformationView().padding()
                    }
                    Spacer()
            }
            .background(Color.card)
        }
        .background(Color.primaryBackground)
    }
}

struct UpdatedProfileFeature_Previews: PreviewProvider {
    static var previews: some View {
        UpdatedProfileFeatureView().preferredColorScheme(.dark)
    }
}
