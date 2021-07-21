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
    @DependencyInjected private static var userDefaults: UserDefaults!
    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    Image(systemName: "person.fill.questionmark")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 150, height: 150)
                        .padding(35)
                        .background(
                            Circle().stroke(Color.white, lineWidth: 4)
                                .shadow(radius: 7)
                        )
                    Text("Your name here").font(.title)
                    Divider()
                }
                VStack {
                    Section(header: Text("Account Information:").font(.title)) {
                        AccountInformationView().padding()
                    }
                    Divider()
                }
                VStack {
                    Button("Clear User Defaults") {
                        Self.userDefaults.dictionaryRepresentation().keys.forEach(Self.userDefaults.removeObject(forKey:))
                    }
                }
                Spacer()
            }
        }
    }
}

struct ProfileFeature_Previews: PreviewProvider {
    static var previews: some View {
        ProfileFeatureView()
    }
}
