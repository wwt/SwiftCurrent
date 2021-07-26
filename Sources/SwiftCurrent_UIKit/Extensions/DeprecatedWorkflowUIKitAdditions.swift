//  swiftlint:disable:this file_name
//  Reason: The file name reflects the contents of the file.
//
//  DeprecatedWorkflowUIKitAdditions.swift
//  Workflow
//
//  Created by Tyler Thompson on 5/5/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import SwiftCurrent

// UI friendly terms for creating a workflow.
extension Workflow {
    /**
     Creates a `Workflow` with a `FlowRepresentable`.
     - Parameter type: a reference to the first `FlowRepresentable`'s concrete type in the workflow.
     - Parameter presentationType: the `LaunchStyle.PresentationType` the flow representable should use while it's part of this workflow.
     - Parameter flowPersistence: the `FlowPersistence` representing how this item in the workflow should persist.
     */
    @available(*, deprecated, renamed: "init(_:launchStyle:flowPersistence:)")
    public convenience init(_ type: F.Type,
                            presentationType: LaunchStyle.PresentationType,
                            flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) {
        self.init(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { _ in flowPersistence() })
    }

    /**
     Creates a `Workflow` with a `FlowRepresentable`.
     - Parameter type: a reference to the first `FlowRepresentable`'s concrete type in the workflow.
     - Parameter presentationType: the `LaunchStyle.PresentationType` the flow representable should use while it's part of this workflow.
     - Parameter flowPersistence: a closure taking in the `FlowRepresentable.WorkflowInput` and returning a `FlowPersistence` representing how this item in the workflow should persist.
     */
    @available(*, deprecated, renamed: "init(_:launchStyle:flowPersistence:)")
    public convenience init(_ type: F.Type,
                            presentationType: LaunchStyle.PresentationType,
                            flowPersistence: @escaping (F.WorkflowInput) -> FlowPersistence) {
        self.init(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { data in
            guard case.args(let extracted) = data,
                  let cast = extracted as? F.WorkflowInput else { return .default }
            return flowPersistence(cast)
        })
    }

    /**
     Creates a `Workflow` with a `FlowRepresentable`.
     - Parameter type: a reference to the first `FlowRepresentable`'s concrete type in the workflow.
     - Parameter presentationType: the `LaunchStyle.PresentationType` the flow representable should use while it's part of this workflow.
     - Parameter flowPersistence: a closure returning a `FlowPersistence` representing how this item in the workflow should persist.
     */
    @available(*, deprecated, renamed: "init(_:launchStyle:flowPersistence:)")
    public convenience init(_ type: F.Type,
                            presentationType: LaunchStyle.PresentationType,
                            flowPersistence: @autoclosure @escaping () -> FlowPersistence) where F.WorkflowInput == Never {
        self.init(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { _ in flowPersistence() })
    }

    /**
     Creates a `Workflow` with a `FlowRepresentable`.
     - Parameter type: a reference to the first `FlowRepresentable`'s concrete type in the workflow.
     - Parameter presentationType: the `LaunchStyle.PresentationType` the flow representable should use while it's part of this workflow.
     - Parameter flowPersistence: a closure returning a `FlowPersistence` representing how this item in the workflow should persist.
     */
    @available(*, deprecated, renamed: "init(_:launchStyle:flowPersistence:)")
    public convenience init(_ type: F.Type,
                            presentationType: LaunchStyle.PresentationType,
                            flowPersistence: @autoclosure @escaping () -> FlowPersistence) where F.WorkflowInput == AnyWorkflow.PassedArgs {
        self.init(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { _ in flowPersistence() })
    }
}

extension Workflow where F.WorkflowOutput == Never {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter presentationType: the `LaunchStyle.PresentationType` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    @available(*, deprecated, renamed: "thenProceed(with:launchStyle:flowPersistence:)")
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                                   presentationType: LaunchStyle.PresentationType = .default,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR> where FR.WorkflowInput == Never {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { _ in flowPersistence() })
        return wf
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter presentationType: the `LaunchStyle.PresentationType` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    @available(*, deprecated, renamed: "thenProceed(with:launchStyle:flowPersistence:)")
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                                   presentationType: LaunchStyle.PresentationType = .default,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR> where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { _ in flowPersistence() })
        return wf
    }
}

extension Workflow {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter presentationType: the `LaunchStyle.PresentationType` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    @available(*, deprecated, renamed: "thenProceed(with:launchStyle:flowPersistence:)")
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                                   presentationType: LaunchStyle.PresentationType = .default,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR> where F.WorkflowOutput == FR.WorkflowInput {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { _ in flowPersistence() })
        return wf
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter presentationType: the `LaunchStyle.PresentationType` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a closure taking in the `FlowRepresentable.WorkflowInput` and returning a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    @available(*, deprecated, renamed: "thenProceed(with:launchStyle:flowPersistence:)")
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                                   presentationType: LaunchStyle.PresentationType = .default,
                                                   flowPersistence: @escaping (FR.WorkflowInput) -> FlowPersistence) -> Workflow<FR> where F.WorkflowOutput == FR.WorkflowInput {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { data in
            guard case.args(let extracted) = data,
                  let cast = extracted as? FR.WorkflowInput else { return .default }
            return flowPersistence(cast)
        })
        return wf
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter presentationType: the `LaunchStyle.PresentationType` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    @available(*, deprecated, renamed: "thenProceed(with:launchStyle:flowPersistence:)")
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                                   presentationType: LaunchStyle.PresentationType = .default,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR> where FR.WorkflowInput == Never {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { _ in flowPersistence() })
        return wf
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter presentationType: the `LaunchStyle.PresentationType` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    @available(*, deprecated, renamed: "thenProceed(with:launchStyle:flowPersistence:)")
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                                   presentationType: LaunchStyle.PresentationType = .default,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR> where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { _ in flowPersistence() })
        return wf
    }
}
