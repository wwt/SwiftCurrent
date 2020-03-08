//
//  DIContainer.swift
//  Workflow
//
//  Created by Tyler Thompson on 12/17/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import Swinject

extension Workflow {
    static var defaultContainer = Container()
}

public extension Workflow {
    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter staysInViewStack: An `ViewPersistance`type representing how this item in the workflow should persist.
    /// - Parameter dependencyInjectionSetup: A closure that hands off a `Container` for you to set up Dependency Injection
    /// - Returns: `Workflow`
    func thenPresent<F>(_ type:F.Type, presentationType:PresentationType = .default, staysInViewStack:@escaping @autoclosure () -> ViewPersistance = .default, dependencyInjectionSetup: ((Container) -> Void)? = nil) -> Workflow where F: FlowRepresentable {
        let wf = Workflow(first)
        dependencyInjectionSetup?(Workflow.defaultContainer)
        wf.append(FlowRepresentableMetaData(type,
                                            presentationType: presentationType,
                                            staysInViewStack: { _ in staysInViewStack() }))
        return wf
    }

    /// thenPresent: A way of creating workflows with a fluid API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter staysInViewStack: A closure taking in the generic type from the `FlowRepresentable` and returning a `ViewPersistance`type representing how this item in the workflow should persist.
    /// - Parameter dependencyInjectionSetup: A closure that hands off a `Container` for you to set up Dependency Injection
    /// - Returns: `Workflow`
    func thenPresent<F>(_ type:F.Type, presentationType:PresentationType = .default, staysInViewStack:@escaping (F.IntakeType) -> ViewPersistance, dependencyInjectionSetup: ((Container) -> Void)? = nil) -> Workflow where F: FlowRepresentable {
        let wf = Workflow(first)
        dependencyInjectionSetup?(Workflow.defaultContainer)
        wf.append(FlowRepresentableMetaData(type,
                                            presentationType: presentationType,
                                            staysInViewStack: { data in
                                                guard let cast = data as? F.IntakeType else { return .default }
                                                return staysInViewStack(cast)
        }))
        return wf
    }

    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter staysInViewStack: A closure returning a `ViewPersistance`type representing how this item in the workflow should persist.
    /// - Parameter dependencyInjectionSetup: A closure that hands off a `Container` for you to set up Dependency Injection
    /// - Returns: `Workflow`
    func thenPresent<F>(_ type:F.Type, presentationType:PresentationType = .default, staysInViewStack:@escaping () -> ViewPersistance, dependencyInjectionSetup: ((Container) -> Void)? = nil) -> Workflow where F: FlowRepresentable, F.IntakeType == Never {
        let wf = Workflow(first)
        dependencyInjectionSetup?(Workflow.defaultContainer)
        wf.append(FlowRepresentableMetaData(type,
                                            presentationType: presentationType,
                                            staysInViewStack: { _ in
                                                return staysInViewStack()
        }))
        return wf
    }
}
