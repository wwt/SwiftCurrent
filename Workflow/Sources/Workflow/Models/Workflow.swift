//
//  Workflow.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/26/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
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

    /**
    A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    - Parameter type: A reference to the class used to create the workflow
    - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
    - Parameter flowPersistence: An `FlowPersistence`type representing how this item in the workflow should persist.
    - Returns: `Workflow`
    */
    public convenience init(_ type: F.Type,
                            launchStyle: LaunchStyle = .default,
                            flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) {
        self.init(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
    }
    /**
    A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    - Parameter type: A reference to the class used to create the workflow
    - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
    - Parameter flowPersistence: A closure taking in the generic type from the `FlowRepresentable` and returning a `FlowPersistence`type representing how this item in the workflow should persist.
    - Returns: `Workflow`
    */
    public convenience init(_ type: F.Type,
                            launchStyle: LaunchStyle = .default,
                            flowPersistence: @escaping (F.WorkflowInput) -> FlowPersistence) {
        self.init(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { data in
            guard case.args(let extracted) = data,
                  let cast = extracted as? F.WorkflowInput else { return .default }
            return flowPersistence(cast)
        })
    }

    /**
    A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    - Parameter type: A reference to the class used to create the workflow
    - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
    - Parameter flowPersistence: A closure returning a `FlowPersistence`type representing how this item in the workflow should persist.
    - Returns: `Workflow`
    */
    public convenience init(_ type: F.Type,
                            launchStyle: LaunchStyle = .default,
                            flowPersistence: @escaping () -> FlowPersistence) where F.WorkflowInput == Never {
        self.init(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
    }

    /**
    A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    - Parameter type: A reference to the class used to create the workflow
    - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
    - Parameter flowPersistence: A closure returning a `FlowPersistence`type representing how this item in the workflow should persist.
    - Returns: `Workflow`
    */
    public convenience init(_ type: F.Type,
                            launchStyle: LaunchStyle = .default,
                            flowPersistence: @escaping () -> FlowPersistence) where F.WorkflowInput == AnyWorkflow.PassedArgs {
        self.init(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
    }
}

extension Workflow where F.WorkflowOutput == Never {
    /**
    A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    - Parameter type: A reference to the class used to create the workflow
    - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
    - Parameter flowPersistence: An `FlowPersistence`type representing how this item in the workflow should persist.
    - Returns: `Workflow`
    */
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                                   launchStyle: LaunchStyle = .default,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR> where FR.WorkflowInput == Never {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
        return wf
    }

    /**
    A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    - Parameter type: A reference to the class used to create the workflow
    - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
    - Parameter flowPersistence: An `FlowPersistence`type representing how this item in the workflow should persist.
    - Returns: `Workflow`
    */
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                                   launchStyle: LaunchStyle = .default,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR>
    where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
        return wf
    }
}

extension Workflow {
    /**
    A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    - Parameter type: A reference to the class used to create the workflow
    - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
    - Parameter flowPersistence: An `FlowPersistence`type representing how this item in the workflow should persist.
    - Returns: `Workflow`
    */
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                                   launchStyle: LaunchStyle = .default,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR> where F.WorkflowOutput == FR.WorkflowInput {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
        return wf
    }

    /**
    A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    - Parameter type: A reference to the class used to create the workflow
    - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
    - Parameter flowPersistence: A closure taking in the generic type from the `FlowRepresentable` and returning a `FlowPersistence`type representing how this item in the workflow should persist.
    - Returns: `Workflow`
    */
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                                   launchStyle: LaunchStyle = .default,
                                                   flowPersistence: @escaping (FR.WorkflowInput) -> FlowPersistence) -> Workflow<FR> where F.WorkflowOutput == FR.WorkflowInput {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { data in
            guard case.args(let extracted) = data,
                  let cast = extracted as? FR.WorkflowInput else { return .default }
            return flowPersistence(cast)
        })
        return wf
    }

    /**
    A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    - Parameter type: A reference to the class used to create the workflow
    - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
    - Parameter flowPersistence: A closure returning a `FlowPersistence`type representing how this item in the workflow should persist.
    - Returns: `Workflow`
    */
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                                   launchStyle: LaunchStyle = .default,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR> where FR.WorkflowInput == Never {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
        return wf
    }

    /**
    A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    - Parameter type: A reference to the class used to create the workflow
    - Parameter launchStyle: A `LaunchStyle` the flow representable should use while it's part of this workflow
    - Parameter flowPersistence: A closure returning a `FlowPersistence`type representing how this item in the workflow should persist.
    - Returns: `Workflow`
    */
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                                   launchStyle: LaunchStyle = .default,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR>
    where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: launchStyle) { _ in flowPersistence() })
        return wf
    }
}
