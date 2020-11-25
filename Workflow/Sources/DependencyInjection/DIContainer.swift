//
//  DIContainer.swift
//  Workflow
//
//  Created by Tyler Thompson on 12/17/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import Swinject
import Workflow

extension AnyWorkflow {
    static var defaultContainer = Container()
}

extension Workflow where F.WorkflowOutput == Never {
    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter staysInViewStack: An `ViewPersistance`type representing how this item in the workflow should persist.
    /// - Parameter dependencyInjectionSetup: A closure that hands off a `Container` for you to set up Dependency Injection
    /// - Returns: `Workflow`
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                                   presentationType: PresentationType = .default,
                                                   staysInViewStack:@escaping @autoclosure () -> FlowPersistance = .default,
                                                   dependencyInjectionSetup: ((Container) -> Void)) -> Workflow<FR> where FR.WorkflowInput == Never {
        let wf = Workflow<FR>(first)
        dependencyInjectionSetup(Workflow.defaultContainer)
        wf.append(FlowRepresentableMetaData(type,
                                            presentationType: presentationType,
                                            staysInViewStack: { _ in staysInViewStack() }))
        return wf
    }
}

public extension Workflow {
    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter staysInViewStack: An `ViewPersistance`type representing how this item in the workflow should persist.
    /// - Parameter dependencyInjectionSetup: A closure that hands off a `Container` for you to set up Dependency Injection
    /// - Returns: `Workflow`
    func thenPresent<FR>(_ type: FR.Type,
                         presentationType: PresentationType = .default,
                         staysInViewStack:@escaping @autoclosure () -> FlowPersistance = .default,
                         dependencyInjectionSetup: ((Container) -> Void)) -> Workflow<FR> where FR: FlowRepresentable, F.WorkflowOutput == FR.WorkflowInput {
        let wf = Workflow<FR>(first)
        dependencyInjectionSetup(Workflow.defaultContainer)
        wf.append(FlowRepresentableMetaData(type,
                                            presentationType: presentationType,
                                            staysInViewStack: { _ in staysInViewStack() }))
        return wf
    }

    /// init: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter staysInViewStack: An `ViewPersistance`type representing how this item in the workflow should persist.
    /// - Parameter dependencyInjectionSetup: A closure that hands off a `Container` for you to set up Dependency Injection
    /// - Returns: `Workflow`
    convenience init(_ type: F.Type,
                     presentationType: PresentationType = .default,
                     staysInViewStack:@escaping @autoclosure () -> FlowPersistance = .default, dependencyInjectionSetup: ((Container) -> Void)) {
        dependencyInjectionSetup(Workflow.defaultContainer)
        self.init(FlowRepresentableMetaData(type,
                                            presentationType: presentationType,
                                            staysInViewStack: { _ in staysInViewStack() }))
    }

    /// thenPresent: A way of creating workflows with a fluid API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter staysInViewStack: A closure taking in the generic type from the `FlowRepresentable` and returning a `ViewPersistance`type representing how this item in the workflow should persist.
    /// - Parameter dependencyInjectionSetup: A closure that hands off a `Container` for you to set up Dependency Injection
    /// - Returns: `Workflow`
    func thenPresent<FR>(_ type: FR.Type,
                         presentationType: PresentationType = .default,
                         staysInViewStack:@escaping (FR.WorkflowInput) -> FlowPersistance,
                         dependencyInjectionSetup: ((Container) -> Void)) -> Workflow<FR> where FR: FlowRepresentable, F.WorkflowOutput == FR.WorkflowInput {
        let wf = Workflow<FR>(first)
        dependencyInjectionSetup(Workflow.defaultContainer)
        wf.append(FlowRepresentableMetaData(type,
                                            presentationType: presentationType,
                                            staysInViewStack: { data in
                                                guard let cast = data as? FR.WorkflowInput else { return .default }
                                                return staysInViewStack(cast)
        }))
        return wf
    }

    /// init: A way of creating workflows with a fluid API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter staysInViewStack: A closure taking in the generic type from the `FlowRepresentable` and returning a `ViewPersistance`type representing how this item in the workflow should persist.
    /// - Parameter dependencyInjectionSetup: A closure that hands off a `Container` for you to set up Dependency Injection
    /// - Returns: `Workflow`
    convenience init(_ type: F.Type,
                     presentationType: PresentationType = .default,
                     staysInViewStack:@escaping (F.WorkflowInput) -> FlowPersistance,
                     dependencyInjectionSetup: ((Container) -> Void)) {
        dependencyInjectionSetup(Workflow.defaultContainer)
        self.init(FlowRepresentableMetaData(type,
                                            presentationType: presentationType,
                                            staysInViewStack: { data in
                                                guard let cast = data as? F.WorkflowInput else { return .default }
                                                return staysInViewStack(cast)
        }))
    }

    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter staysInViewStack: A closure returning a `ViewPersistance`type representing how this item in the workflow should persist.
    /// - Parameter dependencyInjectionSetup: A closure that hands off a `Container` for you to set up Dependency Injection
    /// - Returns: `Workflow`
    func thenPresent<FR>(_ type: FR.Type,
                         presentationType: PresentationType = .default,
                         staysInViewStack:@escaping @autoclosure () -> FlowPersistance = .default,
                         dependencyInjectionSetup: ((Container) -> Void)) -> Workflow<FR> where FR: FlowRepresentable, FR.WorkflowInput == Never {
        let wf = Workflow<FR>(first)
        dependencyInjectionSetup(Workflow.defaultContainer)
        wf.append(FlowRepresentableMetaData(type,
                                            presentationType: presentationType,
                                            staysInViewStack: { _ in
                                                return staysInViewStack()
        }))
        return wf
    }

    /// init: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter staysInViewStack: A closure returning a `ViewPersistance`type representing how this item in the workflow should persist.
    /// - Parameter dependencyInjectionSetup: A closure that hands off a `Container` for you to set up Dependency Injection
    /// - Returns: `Workflow`
    convenience init(_ type: F.Type,
                     presentationType: PresentationType = .default,
                     staysInViewStack:@escaping () -> FlowPersistance,
                     dependencyInjectionSetup: ((Container) -> Void)) where F.WorkflowInput == Never {
        dependencyInjectionSetup(Workflow.defaultContainer)
        self.init(FlowRepresentableMetaData(type,
                                            presentationType: presentationType,
                                            staysInViewStack: { _ in
                                                return staysInViewStack()
        }))
    }
}
