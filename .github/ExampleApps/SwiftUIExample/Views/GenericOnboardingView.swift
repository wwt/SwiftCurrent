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

struct GenericOnboardingView: View, FlowRepresentable {
    private var onboardedToProfileFeature: AppStorage<Bool>
    weak var _workflowPointer: AnyFlowRepresentable?

    let inspection = Inspection<Self>() // ViewInspector
    private let onboardingModel: OnboardingData
    private let continueAction: (() -> Void)?

    /// Called by SwiftCurrent to create a GenericOnboardingView in a Workflow
    init(with model: OnboardingData) {
        onboardingModel = model
        onboardedToProfileFeature = AppStorage(wrappedValue: false, model.appStorageKey, store: .fromDI)
        continueAction = nil
    }

    /// Creates a GenericOnboardingView outside of the context of a Workflow
    init(model: OnboardingData, continueAction: @escaping () -> Void) {
        onboardingModel = model
        onboardedToProfileFeature = AppStorage(wrappedValue: false, model.appStorageKey, store: .fromDI)
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
                onboardedToProfileFeature.wrappedValue = true
                if _workflowPointer != nil { // Running in Workflow
                    proceedInWorkflow()
                } else { // Running as a generic view
                    continueAction?()
                }
            }
        }
        .onReceive(inspection.notice) { inspection.visit(self, $0) } // ViewInspector
    }

    func shouldLoad() -> Bool {
        !onboardedToProfileFeature.wrappedValue
    }
}

struct FeatureValue_Previews: PreviewProvider {
    static var previews: some View {
        GenericOnboardingView(model: OnboardingData(previewImage: .wwtLogo,
                                                    previewAccent: .clear,
                                                    featureTitle: "Feature title",
                                                    featureSummary: "Feature summary",
                                                    appStorageKey: "FeatureValue_Previews",
                                                    appStorageStore: nil)) {
            print("Continued")
        }.preferredColorScheme(.dark)
    }
}
