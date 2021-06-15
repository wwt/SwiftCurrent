//  swiftlint:disable:this file_name
//  Reason: The file name reflects the contents of the file.
//
//  WorkflowUIKitAdditions.swift
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
    public convenience init(_ type: F.Type,
                            presentationType: LaunchStyle.PresentationType,
                            flowPersistence: @autoclosure @escaping () -> FlowPersistence) where F.WorkflowInput == AnyWorkflow.PassedArgs {
        self.init(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { _ in flowPersistence() })
    }
}

extension Workflow {
    /**
     Called when the workflow should be terminated, and the app should return to the point before the workflow was launched.
     - Parameter animated: a boolean indicating whether abandoning the workflow should be animated.
     - Parameter onFinish: a callback after the workflow has been abandoned.
     - Important: In order to dismiss UIKit views the workflow must have an `OrchestrationResponder` that is a `UIKitPresenter`.
     */
    public func abandon(animated: Bool = true, onFinish:(() -> Void)? = nil) {
        AnyWorkflow(self).abandon(animated: animated, onFinish: onFinish)
    }
}

extension AnyWorkflow {
    /**
     Called when the workflow should be terminated, and the app should return to the point before the workflow was launched.
     - Parameter animated: a boolean indicating whether abandoning the workflow should be animated.
     - Parameter onFinish: a callback after the workflow has been abandoned.
     - Important: In order to dismiss UIKit views the workflow must have an `OrchestrationResponder` that is a `UIKitPresenter`.
     */
    public func abandon(animated: Bool = true, onFinish:(() -> Void)? = nil) {
        if let presenter = orchestrationResponder as? UIKitPresenter {
            presenter.abandon(self, animated: animated) { [weak self] in
                self?._abandon()
                onFinish?()
            }
        } else if let responder = orchestrationResponder {
            responder.abandon(self) { [weak self] in
                self?._abandon()
                onFinish?()
            }
        } else {
            _abandon()
        }
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
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                                   presentationType: LaunchStyle.PresentationType = .default,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR> where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { _ in flowPersistence() })
        return wf
    }
}
