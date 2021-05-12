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
import Workflow

// UI friendly terms for creating a workflow.
extension Workflow {
    /**
    A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    - Parameter type: A reference to the class used to create the workflow
    - Parameter presentationType: The `PresentationType` the flow representable should use while it's part of this workflow
    - Parameter flowPersistence: The `FlowPersistence` type representing how this item in the workflow should persist.
    - Returns: `Workflow`
    */
    public convenience init(_ type: F.Type,
                            presentationType: LaunchStyle.PresentationType,
                            flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) {
        self.init(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { _ in flowPersistence() })
    }

    /**
    A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    - Parameter type: A reference to the class used to create the workflow
    - Parameter presentationType: The `PresentationType` the flow representable should use while it's part of this workflow
    - Parameter flowPersistence: A closure taking in the `FlowRepresentable.WorkflowInput` and returning a `FlowPersistence` type representing how this item in the workflow should persist.
    - Returns: `Workflow`
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
    A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    - Parameter type: A reference to the class used to create the workflow
    - Parameter presentationType: The `PresentationType` the flow representable should use while it's part of this workflow
    - Parameter flowPersistence: A closure returning a `FlowPersistence` type representing how this item in the workflow should persist.
    - Returns: `Workflow`
    */
    public convenience init(_ type: F.Type,
                            presentationType: LaunchStyle.PresentationType,
                            flowPersistence: @escaping () -> FlowPersistence) where F.WorkflowInput == Never {
        self.init(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { _ in flowPersistence() })
    }

    /**
    A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    - Parameter type: A reference to the class used to create the workflow
    - Parameter presentationType: The `PresentationType` the flow representable should use while it's part of this workflow
    - Parameter flowPersistence: A closure returning a `FlowPersistence` type representing how this item in the workflow should persist.
    - Returns: `Workflow`
    */
    public convenience init(_ type: F.Type,
                            presentationType: LaunchStyle.PresentationType,
                            flowPersistence: @escaping () -> FlowPersistence) where F.WorkflowInput == AnyWorkflow.PassedArgs {
        self.init(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { _ in flowPersistence() })
    }
}

extension Workflow {
    /**
    Called when the workflow should be terminated, and the app should return to the point before the workflow was launched
    - Parameter animated: A boolean indicating whether abandoning the workflow should be animated
    - Parameter onFinish: A callback after the workflow has been abandoned.
    - Note: In order to dismiss UIKit views the workflow must have an `OrchestrationResponder` that is a `UIKitPresenter`.
    */
    public func abandon(animated: Bool = true, onFinish:(() -> Void)? = nil) {
        AnyWorkflow(self).abandon(animated: animated, onFinish: onFinish)
    }
}

extension AnyWorkflow {
    /**
    Called when the workflow should be terminated, and the app should return to the point before the workflow was launched
    - Parameter animated: A boolean indicating whether abandoning the workflow should be animated
    - Parameter onFinish: A callback after the workflow has been abandoned.
    - Note: In order to dismiss UIKit views the workflow must have an `OrchestrationResponder` that is a `UIKitPresenter`.
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
    A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    - Parameter type: A reference to the class used to create the workflow
    - Parameter presentationType: The `PresentationType` the flow representable should use while it's part of this workflow
    - Parameter flowPersistence: The `FlowPersistence`type representing how this item in the workflow should persist.
    - Returns: `Workflow`
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
    A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    - Parameter type: A reference to the class used to create the workflow
    - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    - Parameter flowPersistence: An `FlowPersistence`type representing how this item in the workflow should persist.
    - Returns: `Workflow`
    */
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                                   presentationType: LaunchStyle.PresentationType = .default,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR>
    where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { _ in flowPersistence() })
        return wf
    }
}

extension Workflow {
    /**
    A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    - Parameter type: A reference to the class used to create the workflow
    - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    - Parameter flowPersistence: An `FlowPersistence`type representing how this item in the workflow should persist.
    - Returns: `Workflow`
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
    A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    - Parameter type: A reference to the class used to create the workflow
    - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    - Parameter flowPersistence: A closure taking in the generic type from the `FlowRepresentable` and returning a `FlowPersistence`type representing how this item in the workflow should persist.
    - Returns: `Workflow`
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
    A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    - Parameter type: A reference to the class used to create the workflow
    - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    - Parameter flowPersistence: A closure returning a `FlowPersistence`type representing how this item in the workflow should persist.
    - Returns: `Workflow`
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
    A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    - Parameter type: A reference to the class used to create the workflow
    - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    - Parameter flowPersistence: A closure returning a `FlowPersistence`type representing how this item in the workflow should persist.
    - Returns: `Workflow`
    */
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                                   presentationType: LaunchStyle.PresentationType = .default,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR>
    where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { _ in flowPersistence() })
        return wf
    }
}
