//
//  GenericOnboardingView.swift
//  SwiftUIExample
//
//  Created by Richard Gist on 9/22/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent
import Swinject

struct OnboardingModel {
    let previewImage: Image
    let previewAccent: Color
    let featureTitle: String
    let featureSummary: String
    let appStorageKey: String

    static let profileFeature = OnboardingModel(previewImage: .profileOnboarding,
                                                previewAccent: .icon,
                                                featureTitle: "Welcome to our new profile management feature!",
                                                featureSummary: "You can update your username and password here.",
                                                appStorageKey: "OnboardedToProfileFeature")

    static let mapFeature = OnboardingModel(previewImage: .logo,
                                            previewAccent: .icon,
                                            featureTitle: "Maps!",
                                            featureSummary: "We've got all kinds of maps like this one.",
                                            appStorageKey: "MapOnboardingFeature")
}

struct GenericOnboardingView: View, FlowRepresentable {
    @DependencyInjected private static var userDefaults: UserDefaults!

    let inspection = Inspection<Self>() // ViewInspector
    weak var _workflowPointer: AnyFlowRepresentable?
    private let onboardingModel: OnboardingModel
    private let continueAction: (() -> Void)?

    init(with model: OnboardingModel) {
        onboardingModel = model
        continueAction = { print("This worked as I expected?") }
    }

    init(model: OnboardingModel, continueAction: @escaping () -> Void) {
        onboardingModel = model
        self.continueAction = continueAction
    }

    var body: some View {
        VStack {
            VStack {
                onboardingModel.previewImage
                    .resizable()
                    .scaledToFit()
                    .shadow(color: onboardingModel.previewAccent, radius: 5)
                    .padding()

                Text(onboardingModel.featureTitle)
                    .titleStyle()
                    .multilineTextAlignment(.center)
                Text(onboardingModel.featureSummary)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                Spacer()
            }
            PrimaryButton(title: "Continue") {
                Self.userDefaults.set(true, forKey: onboardingModel.appStorageKey)
                continueAction?()
                proceedInWorkflow()
            }
        }
        .onReceive(inspection.notice) { inspection.visit(self, $0) } // ViewInspector
    }

    func shouldLoad() -> Bool {
        !Self.userDefaults.bool(forKey: onboardingModel.appStorageKey)
    }
}

struct FeatureValue_Previews: PreviewProvider {
    static var previews: some View {
        GenericOnboardingView()
            .preferredColorScheme(.dark)
    }
}
