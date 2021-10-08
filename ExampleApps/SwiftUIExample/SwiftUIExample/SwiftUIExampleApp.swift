//
//  SwiftUIExampleApp.swift
//  SwiftUIExample
//
//  Created by Tyler Thompson on 7/15/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import SwiftUI
import Swinject
import SwiftCurrent_SwiftUI

@main
struct SwiftUIExampleApp: App {
    init() {
        Container.default.register(UserDefaults.self) { _ in UserDefaults.standard }
    }

    var body: some Scene {
        WindowGroup {
            if Environment.shouldTest {
                TestView()
            } else {
                WorkflowLauncher(isLaunched: .constant(true)) {
                    thenProceed(with: SwiftCurrentOnboarding.self) {
                        thenProceed(with: ContentView.self)
                            .applyModifiers { $0.transition(.slide) }
                    }.applyModifiers { $0.transition(.slide) }
                }
                .preferredColorScheme(.dark)
            }
        }
    }
}
