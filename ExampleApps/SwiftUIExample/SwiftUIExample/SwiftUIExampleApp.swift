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
                WorkflowView(launchingWith: expectedArgument) {
//                    WorkflowItem { FRR1().shouldLoad(false) }
                    WorkflowItem { (input: String) in FRR2(with: input) }
                }
//                WorkflowView {
//                    WorkflowItem { SwiftCurrentOnboarding().transition(.slide) }
//                        .presentationType(.modal)
//                    WorkflowItem { ContentView().transition(.slide) }
//                }
                .preferredColorScheme(.dark)
            }
        }
    }
}

struct FRR1: View {
    var body: some View { Text(String(describing: Self.self)) }
}
struct FRR2: View {
    var body: some View { Text("\(String(describing: Self.self)) INPUT: \(input)") }
    var input: String
    init(with input: String) { self.input = input }
}
let expectedArgument = UUID().uuidString
