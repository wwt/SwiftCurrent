//  swiftlint:disable:this file_name
//  WorkflowExtensions.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 7/13/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftCurrent
import SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension Workflow where F: FlowRepresentable & View {
    /**
     Creates a `Workflow` with a `FlowRepresentable`.
     - Parameter type: a reference to the first `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a `FlowPersistence` representing how this item in the workflow should persist.
     */
    public convenience init(_ type: F.Type,
                            launchStyle: LaunchStyle = .default,
                            flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) {
        self.init(ExtendedFlowRepresentableMetadata(flowRepresentableType: type,
                                                    launchStyle: launchStyle) { _ in flowPersistence() })
    }

    /**
     Creates a `Workflow` with a `FlowRepresentable`.
     - Parameter type: a reference to the first `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a `FlowPersistence` representing how this item in the workflow should persist.
     */
    public convenience init(_ type: F.Type,
                            launchStyle: LaunchStyle = .default,
                            flowPersistence: @escaping (F.WorkflowInput) -> FlowPersistence) {
        self.init(ExtendedFlowRepresentableMetadata(flowRepresentableType: type,
                                                    launchStyle: launchStyle) { data in
            guard case.args(let extracted) = data,
                  let cast = extracted as? F.WorkflowInput else { return .default }

            return flowPersistence(cast)
        })
    }

    /**
     Creates a `Workflow` with a `FlowRepresentable`.
     - Parameter type: a reference to the first `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a closure returning a `FlowPersistence` representing how this item in the workflow should persist.
     */
    public convenience init(_ type: F.Type,
                            launchStyle: LaunchStyle = .default,
                            flowPersistence: @escaping () -> FlowPersistence) where F.WorkflowInput == Never {
        self.init(ExtendedFlowRepresentableMetadata(flowRepresentableType: type,
                                                    launchStyle: launchStyle) { _ in flowPersistence() })
    }

    /// Called when the workflow should be terminated, and the app should return to the point before the workflow was launched.
    public func abandon() {
        AnyWorkflow(self).abandon()
    }

    // TODO: Remove the following untested functions when data-driven is more mature

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a closure returning a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable & View>(with type: FR.Type,
                                                          launchStyle: LaunchStyle = .default,
                                                          flowPersistence: @escaping (FR.WorkflowInput) -> FlowPersistence) -> Workflow<FR> where F.WorkflowOutput == FR.WorkflowInput {
        let workflow = Workflow<FR>(first)
        workflow.append(ExtendedFlowRepresentableMetadata(flowRepresentableType: type,
                                                          launchStyle: launchStyle) { data in
            guard case.args(let extracted) = data,
                  let cast = extracted as? FR.WorkflowInput else { return .default }

            return flowPersistence(cast)
        })
        return workflow
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a closure returning a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    public func thenProceed<F: FlowRepresentable & View>(with type: F.Type,
                                                         launchStyle: LaunchStyle = .default,
                                                         flowPersistence: @escaping (F.WorkflowInput) -> FlowPersistence) -> Workflow<F> where F.WorkflowInput == AnyWorkflow.PassedArgs {
        let workflow = Workflow<F>(first)
        workflow.append(ExtendedFlowRepresentableMetadata(flowRepresentableType: type,
                                                          launchStyle: launchStyle) { data in
            guard case.args(let extracted) = data,
                  let cast = extracted as? F.WorkflowInput else { return .default }

            return flowPersistence(cast)
        })
        return workflow
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension Workflow where F: FlowRepresentable & View, F.WorkflowOutput == Never {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a closure returning a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    public func thenProceed<F: FlowRepresentable & View>(with type: F.Type,
                                                         launchStyle: LaunchStyle = .default,
                                                         flowPersistence: @escaping () -> FlowPersistence) -> Workflow<F> where F.WorkflowInput == AnyWorkflow.PassedArgs {
        let workflow = Workflow<F>(first)
        workflow.append(ExtendedFlowRepresentableMetadata(flowRepresentableType: type,
                                                          launchStyle: launchStyle) { _ in flowPersistence() })
        return workflow
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a closure returning a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    public func thenProceed<F: FlowRepresentable & View>(with type: F.Type,
                                                         launchStyle: LaunchStyle = .default,
                                                         flowPersistence: @escaping () -> FlowPersistence) -> Workflow<F> where F.WorkflowInput == Never {
        let workflow = Workflow<F>(first)
        workflow.append(ExtendedFlowRepresentableMetadata(flowRepresentableType: type,
                                                          launchStyle: launchStyle) { _ in flowPersistence() })
        return workflow
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable & View>(with type: FR.Type,
                                                          launchStyle: LaunchStyle = .default,
                                                          flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR> where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        let wf = Workflow<FR>(first)
        wf.append(ExtendedFlowRepresentableMetadata(flowRepresentableType: type,
                                                    launchStyle: launchStyle) { _ in flowPersistence() })
        return wf
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension Workflow where F: FlowRepresentable & View, F.WorkflowOutput == AnyWorkflow.PassedArgs {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a closure returning a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    public func thenProceed<F: FlowRepresentable & View>(with type: F.Type,
                                                         launchStyle: LaunchStyle = .default,
                                                         flowPersistence: @escaping () -> FlowPersistence) -> Workflow<F> where F.WorkflowInput == AnyWorkflow.PassedArgs {
        let workflow = Workflow<F>(first)
        workflow.append(ExtendedFlowRepresentableMetadata(flowRepresentableType: type,
                                                          launchStyle: launchStyle) { _ in flowPersistence() })
        return workflow
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a closure returning a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    public func thenProceed<F: FlowRepresentable & View>(with type: F.Type,
                                                         launchStyle: LaunchStyle = .default,
                                                         flowPersistence: @escaping (F.WorkflowInput) -> FlowPersistence) -> Workflow<F> where F.WorkflowInput == AnyWorkflow.PassedArgs {
        let workflow = Workflow<F>(first)
        workflow.append(ExtendedFlowRepresentableMetadata(flowRepresentableType: type,
                                                          launchStyle: launchStyle) { data in
            guard case.args(let extracted) = data,
                  let cast = extracted as? F.WorkflowInput else { return .default }

            return flowPersistence(cast)
        })
        return workflow
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a closure returning a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    public func thenProceed<F: FlowRepresentable & View>(with type: F.Type,
                                                         launchStyle: LaunchStyle = .default,
                                                         flowPersistence: @escaping () -> FlowPersistence) -> Workflow<F> where F.WorkflowInput == Never {
        let workflow = Workflow<F>(first)
        workflow.append(ExtendedFlowRepresentableMetadata(flowRepresentableType: type,
                                                          launchStyle: launchStyle) { _ in flowPersistence() })
        return workflow
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a closure returning a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    public func thenProceed<F: FlowRepresentable & View>(with type: F.Type,
                                                         launchStyle: LaunchStyle = .default,
                                                         flowPersistence: @escaping (F.WorkflowInput) -> FlowPersistence) -> Workflow<F> {
        let workflow = Workflow<F>(first)
        workflow.append(ExtendedFlowRepresentableMetadata(flowRepresentableType: type,
                                                          launchStyle: launchStyle) { data in
            guard case.args(let extracted) = data,
                  let cast = extracted as? F.WorkflowInput else { return .default }

            return flowPersistence(cast)
        })
        return workflow
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension Workflow where F.WorkflowOutput == Never {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the `FlowRepresentable.WorkflowInput` of this item.
     - Parameter type: a reference to the next `FlowRepresentable`'s concrete type in the workflow.
     - Parameter launchStyle: the `LaunchStyle` the `FlowRepresentable` should use while it's part of this workflow.
     - Parameter flowPersistence: a `FlowPersistence` representing how this item in the workflow should persist.
     - Returns: a new workflow with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable & View>(with type: FR.Type,
                                                          launchStyle: LaunchStyle = .default,
                                                          flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR> where FR.WorkflowInput == Never {
        let wf = Workflow<FR>(first)
        wf.append(ExtendedFlowRepresentableMetadata(flowRepresentableType: type,
                                                    launchStyle: launchStyle) { _ in flowPersistence() })
        return wf
    }
}
