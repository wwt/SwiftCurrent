//
//  Workflow.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/26/19.
//  Copyright © 2019 Tyler Tompson. All rights reserved.
//

import Foundation

/**
 Workflow: A doubly linked list of AnyFlowRepresentable types. Can be used to create a user flow.
 
 Examples:
 ```swift
 let workflow = Workflow(SomeFlowRepresentableClass.self)
                    .thenPresent(SomeOtherFlowRepresentableClass.self, launchStyle: .navigationStack)
 ```

 ### Discussion:
 In a sufficiently complex application it may make sense to create a structure to hold onto all the workflows in an application.
 Example
 ```swift
 struct Workflows {
    static let schedulingFlow = Workflow(SomeFlowRepresentableClass.self)
                                 .thenPresent(SomeOtherFlowRepresentableClass.self, launchStyle: .navigationStack)
 }
 ```
 */

public final class Workflow<F: FlowRepresentable>: AnyWorkflow {
    public required init(_ node: AnyWorkflow.Element?) {
        super.init(node)
    }

    /// init: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistance: An `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public convenience init(_ type: F.Type,
                            launchStyle: LaunchStyle = .default,
                            flowPersistance:@escaping @autoclosure () -> FlowPersistance = .default) {
        self.init(FlowRepresentableMetaData(type,
                                             launchStyle: launchStyle,
                                             flowPersistance: { _ in flowPersistance() }))
    }
    /// init: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistance: A closure taking in the generic type from the `FlowRepresentable` and returning a `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public convenience init(_ type: F.Type,
                            launchStyle: LaunchStyle = .default,
                            flowPersistance:@escaping (F.WorkflowInput) -> FlowPersistance) {
        self.init(FlowRepresentableMetaData(type,
                                            launchStyle: launchStyle,
                                            flowPersistance: { data in
                                                guard let cast = data as? F.WorkflowInput else { return .default }
                                                return flowPersistance(cast)
        }))
    }

    /// init: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistance: A closure returning a `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public convenience init(_ type: F.Type,
                            launchStyle: LaunchStyle = .default,
                            flowPersistance:@escaping () -> FlowPersistance) where F.WorkflowInput == Never {
        self.init(FlowRepresentableMetaData(type,
                                            launchStyle: launchStyle,
                                            flowPersistance: { _ in
                                                return flowPersistance()
        }))
    }
}

public extension Workflow where F.WorkflowOutput == Never {
    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistance: An `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                            launchStyle: LaunchStyle = .default,
                                            flowPersistance:@escaping @autoclosure () -> FlowPersistance = .default) -> Workflow<FR> where FR.WorkflowInput == Never {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetaData(type,
                                            launchStyle: launchStyle,
                                            flowPersistance: { _ in
                                                return flowPersistance()
        }))
        return wf
    }
}

public extension Workflow {
    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistance: An `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                            launchStyle: LaunchStyle = .default,
                                            flowPersistance:@escaping @autoclosure () -> FlowPersistance = .default) -> Workflow<FR> where F.WorkflowOutput == FR.WorkflowInput {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetaData(type,
                                            launchStyle: launchStyle,
                                            flowPersistance: { _ in flowPersistance() }))
        return wf
    }

    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistance: A closure taking in the generic type from the `FlowRepresentable` and returning a `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                            launchStyle: LaunchStyle = .default,
                                            flowPersistance:@escaping (FR.WorkflowInput) -> FlowPersistance) -> Workflow<FR> where F.WorkflowOutput == FR.WorkflowInput {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetaData(type,
                                            launchStyle: launchStyle,
                                            flowPersistance: { data in
                                                guard let cast = data as? FR.WorkflowInput else { return .default }
                                                return flowPersistance(cast)
        }))
        return wf
    }

    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistance: A closure returning a `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                            launchStyle: LaunchStyle = .default,
                                            flowPersistance:@escaping @autoclosure () -> FlowPersistance = .default) -> Workflow<FR> where FR.WorkflowInput == Never {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetaData(type,
                                            launchStyle: launchStyle,
                                            flowPersistance: { _ in
                                                return flowPersistance()
        }))
        return wf
    }
}
