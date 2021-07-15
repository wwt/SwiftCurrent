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
    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
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
            Section(header: Text("Account Information:").font(.title)) {
                AccountInformationView()
            }
            Divider()
            Section(header: Text("Personal Information:").font(.title)) {
                Text("name")
                Text("address")
            }
            Divider()
            Section(header: Text("Card Information:").font(.title)) {
                Text("Drivers License Number")
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
