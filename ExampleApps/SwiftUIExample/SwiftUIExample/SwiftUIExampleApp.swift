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
    let startingWorkflow: AnyWorkflow

    init() {
        Container.default.register(UserDefaults.self) { _ in UserDefaults.standard }

        DataDriven.shared.register(ExtendedFlowRepresentableMetadata(flowRepresentableType: SwiftCurrentOnboarding.self), for: "SwiftCurrentOnboarding")
        DataDriven.shared.register(key: ContentView.self, creating: ExtendedFlowRepresentableMetadata(flowRepresentableType: ContentView.self))
        DataDriven.register(type: LoginView.self)
        print(DataDriven.shared.registryDescription)

        do {
            startingWorkflow = try DataDriven.shared.getWorkflow(from: ["SwiftCurrentOnboarding", "ContentView"])
        } catch {
            let defaultWorkflow = Workflow(ContentView.self)
            startingWorkflow = AnyWorkflow(defaultWorkflow)
        }
    }

    var body: some Scene {
        WindowGroup {
            if Environment.shouldTest {
                TestView()
            } else {
//                WorkflowLauncher(isLaunched: .constant(true)) {
//                    thenProceed(with: SwiftCurrentOnboarding.self) {
//                        thenProceed(with: ContentView.self)
//                            .applyModifiers { $0.transition(.slide) }
//                    }.applyModifiers { $0.transition(.slide) }
//                }
                WorkflowLauncher(isLaunched: .constant(true), workflow: startingWorkflow)
                .preferredColorScheme(.dark)
            }
        }
    }
}

import SwiftCurrent
/// Manages ``FlowRepresentable`` types that will be driven through data.
open class DataDriven {
    // I don't like this.
    static let shared = DataDriven()

    private var registry1 = [String: ExtendedFlowRepresentableMetadata]()

    // I'm leaning towards this being the preferred registry.
    private var registry2 = [String: () -> ExtendedFlowRepresentableMetadata]()

    /// Current human readable description of the registry.
    public var registryDescription: String {
        var stringy = "Registry contains:\n"
        for thisKey in registry1.keys {
            stringy += "  - key: \"\(thisKey)\" : \(registry1[thisKey]!.underlyingTypeDescription)\n"
        }
        return stringy
    }

    func register(_ efrm: @escaping @autoclosure () -> ExtendedFlowRepresentableMetadata, for key: String) {
        registry1[key] = efrm()
        registry2[key] = efrm
    }

    func register(key: Any, creating efrm: @escaping @autoclosure () -> ExtendedFlowRepresentableMetadata) {
        let key = String(describing: key)
        print("Registering key: \(key)")
        registry1[key] = efrm()
        registry2[key] = efrm
    }

    /// Registers the provided type in the data driven registry.
    public class func register<FR: FlowRepresentable & View>(type: FR.Type) {
        let key = String(describing: type)
        let closure = { return ExtendedFlowRepresentableMetadata(flowRepresentableType: type) }

        // This thing could be a instance method that doesn't go directly to shared.  Maybe it could take in shared, I'm not sure.
        shared.registry1[key] = closure()
        shared.registry2[key] = closure
    }

    func getWorkflow(from types: [String]) throws -> AnyWorkflow {
        let workflow = AnyWorkflow.empty
        for thing in types {
            if let efrm = registry2[thing] {
                workflow.append(efrm())
            } else {
                throw Error.unregisteredType
            }
        }

        return workflow
    }

    enum Error: Swift.Error {
        case unregisteredType
    }
}
