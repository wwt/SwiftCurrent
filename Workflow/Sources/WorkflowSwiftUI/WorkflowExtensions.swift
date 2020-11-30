//
//  WorkflowExtensions.swift
//  
//
//  Created by Tyler Thompson on 11/29/20.
//

import Foundation
import Workflow

extension Workflow {

    /// init: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistance: An `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public convenience init(_ type: F.Type,
                            presentationType: LaunchStyle.PresentationType,
                            flowPersistance:@escaping @autoclosure () -> FlowPersistance = .default) {
        self.init(FlowRepresentableMetaData(type,
                                            launchStyle: presentationType.rawValue,
                                            flowPersistance: { _ in flowPersistance() }))
    }
    /// init: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistance: A closure taking in the generic type from the `FlowRepresentable` and returning a `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public convenience init(_ type: F.Type,
                            presentationType: LaunchStyle.PresentationType,
                            flowPersistance:@escaping (F.WorkflowInput) -> FlowPersistance) {
        self.init(FlowRepresentableMetaData(type,
                                            launchStyle: presentationType.rawValue,
                                            flowPersistance: { data in
                                                guard case.args(let extracted) = data,
                                                      let cast = extracted as? F.WorkflowInput else { return .default }
                                                return flowPersistance(cast)
                                            }))
    }

    /// init: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistance: A closure returning a `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public convenience init(_ type: F.Type,
                            presentationType: LaunchStyle.PresentationType,
                            flowPersistance:@escaping () -> FlowPersistance) where F.WorkflowInput == Never {
        self.init(FlowRepresentableMetaData(type,
                                            launchStyle: presentationType.rawValue,
                                            flowPersistance: { _ in
                                                return flowPersistance()
                                            }))
    }

    /// init: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistance: A closure returning a `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public convenience init(_ type: F.Type,
                            presentationType: LaunchStyle.PresentationType,
                            flowPersistance:@escaping () -> FlowPersistance) where F.WorkflowInput == AnyWorkflow.PassedArgs {
        self.init(FlowRepresentableMetaData(type,
                                            launchStyle: presentationType.rawValue,
                                            flowPersistance: { _ in
                                                return flowPersistance()
                                            }))
    }
}

public extension Workflow where F.WorkflowOutput == Never {
    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistance: An `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                            presentationType: LaunchStyle.PresentationType,
                                            flowPersistance:@escaping @autoclosure () -> FlowPersistance = .default) -> Workflow<FR> where FR.WorkflowInput == Never {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetaData(type,
                                            launchStyle: presentationType.rawValue,
                                            flowPersistance: { _ in
                                                return flowPersistance()
                                            }))
        return wf
    }

    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistance: An `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                            presentationType: LaunchStyle.PresentationType,
                                            flowPersistance:@escaping @autoclosure () -> FlowPersistance = .default) -> Workflow<FR>
                                                                                                                        where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetaData(type,
                                            launchStyle: presentationType.rawValue,
                                            flowPersistance: { _ in
                                                return flowPersistance()
                                            }))
        return wf
    }
}

public extension Workflow {
    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistance: An `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                            presentationType: LaunchStyle.PresentationType,
                                            flowPersistance:@escaping @autoclosure () -> FlowPersistance = .default) -> Workflow<FR> where F.WorkflowOutput == FR.WorkflowInput {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetaData(type,
                                            launchStyle: presentationType.rawValue,
                                            flowPersistance: { _ in flowPersistance() }))
        return wf
    }

    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistance: A closure taking in the generic type from the `FlowRepresentable` and returning a `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                            presentationType: LaunchStyle.PresentationType,
                                            flowPersistance:@escaping (FR.WorkflowInput) -> FlowPersistance) -> Workflow<FR> where F.WorkflowOutput == FR.WorkflowInput {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetaData(type,
                                            launchStyle: presentationType.rawValue,
                                            flowPersistance: { data in
                                                guard case.args(let extracted) = data,
                                                      let cast = extracted as? FR.WorkflowInput else { return .default }
                                                return flowPersistance(cast)
                                            }))
        return wf
    }

    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistance: A closure returning a `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                            presentationType: LaunchStyle.PresentationType,
                                            flowPersistance:@escaping @autoclosure () -> FlowPersistance = .default) -> Workflow<FR> where FR.WorkflowInput == Never {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetaData(type,
                                            launchStyle: presentationType.rawValue,
                                            flowPersistance: { _ in
                                                return flowPersistance()
                                            }))
        return wf
    }

    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistance: A closure returning a `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                            presentationType: LaunchStyle.PresentationType,
                                            flowPersistance:@escaping @autoclosure () -> FlowPersistance = .default) -> Workflow<FR>
                                                                                                                        where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetaData(type,
                                            launchStyle: presentationType.rawValue,
                                            flowPersistance: { _ in
                                                return flowPersistance()
                                            }))
        return wf
    }
}
