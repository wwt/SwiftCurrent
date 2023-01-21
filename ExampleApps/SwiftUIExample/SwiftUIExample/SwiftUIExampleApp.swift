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

    @State var flag = false

    var body: some Scene {
        WindowGroup {
            if Environment.shouldTest {
                TestView()
            } else {
                NavigationStack {
                    WorkflowView {
                        WorkflowItem { FR1() }
                        WorkflowItem { FR2() }
                        WorkflowItem { FR3() }
                        WorkflowItem { FR4() }
//                        WorkflowItem { SwiftCurrentOnboarding().transition(.slide) }
//                        WorkflowItem { ContentView().transition(.slide) }
                    }
                }
                .preferredColorScheme(.dark)
            }
        }
    }
}
