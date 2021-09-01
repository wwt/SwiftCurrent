//
//  SwiftUIExampleApp.swift
//  SwiftUIExample
//
//  Created by Tyler Thompson on 7/15/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import SwiftUI
import Swinject
import Foundation

@main
struct SwiftUIExampleApp: App {
    init() {
        Container.default.register(UserDefaults.self) { _ in UserDefaults.standard }
    }

    var body: some Scene {
        WindowGroup {
            if let testing = ProcessInfo.processInfo.environment["XCUITest"] {
                TestingView()
            } else {
                ContentView()
            }
        }
    }
}

struct TestingView: View {
    var body: some View {
        Text("\(ProcessInfo.processInfo.environment["someOtherKey"]!)")
    }
}
