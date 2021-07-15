//
//  ProfileFeatureView.swift
//  SwiftUIExampleApp
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
        VStack { // swiftlint:disable:this closure_body_length
            Group {
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
            Group {
                Section(header: Text("Account Information:").font(.title)) {
                    AccountInformationView().padding()
                }
                Divider()
            }
            Group {
                Section(header: Text("Personal Information:").font(.title)) {
                    Text("name")
                    Text("address")
                }
                Divider()
            }
            Group {
                Section(header: Text("Card Information:").font(.title)) {
                    CardInformationView()
                }
                Divider()
            }
            Group {
                Button("Clear User Defaults") {
                    Self.userDefaults.dictionaryRepresentation().keys.forEach(Self.userDefaults.removeObject(forKey:))
                }
            }
            Spacer()
        }
    }
}

struct ProfileFeature_Previews: PreviewProvider {
    static var previews: some View {
        ProfileFeatureView()
    }
}
