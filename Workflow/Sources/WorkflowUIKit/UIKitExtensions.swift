//
//  UIKitExtensions.swift
//  
//
//  Created by Tyler Thompson on 11/26/20.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import UIKit
import Workflow

extension UIModalPresentationStyle {
    static func styleFor(_ style: LaunchStyle.PresentationType.ModalPresentationStyle) -> UIModalPresentationStyle? {
        switch style {
            case .fullScreen: return .fullScreen
            case .pageSheet: return .pageSheet
            case .formSheet: return .formSheet
            case .currentContext: return .currentContext
            case .custom: return .custom
            case .overFullScreen: return .overFullScreen
            case .overCurrentContext: return .overCurrentContext
            case .popover: return .popover
            case .automatic: if #available(iOS 13.0, *) {
                return .automatic
            }
            default: return nil
        }
        return nil
    }
}

extension UIViewController {
    /// launchInto: When using UIKit this is how you launch a workflow
    /// - Parameter workflow: `Workflow` to launch
    /// - Parameter args: Args to pass to the first `FlowRepresentable`
    /// - Parameter launchStyle: The `PresentationType` used to launch the workflow
    /// - Parameter onFinish: A callback that is called when the last item in the workflow calls back
    /// - Note: In the background this applies a UIKitPresenter, if you call launch on workflow directly you'll need to apply one yourself
    public func launchInto(_ workflow: AnyWorkflow, args: Any? = nil, withLaunchStyle launchStyle: LaunchStyle.PresentationType = .default, onFinish: ((Any?) -> Void)? = nil) {
        workflow.applyOrchestrationResponder(UIKitPresenter(self, launchStyle: launchStyle))
        workflow.launch(with: args,
                        withLaunchStyle: launchStyle.rawValue,
                        onFinish: onFinish)
        #if canImport(XCTest)
        NotificationCenter.default.post(name: .workflowLaunched, object: [
            "workflow": workflow,
            "launchFrom": self,
            "args": args,
            "style": launchStyle,
            "onFinish": onFinish
        ])
        #endif
    }

    /// launchInto: When using UIKit this is how you launch a workflow
    /// - Parameter workflow: `Workflow` to launch
    /// - Parameter launchStyle: The `PresentationType` used to launch the workflow
    /// - Parameter onFinish: A callback that is called when the last item in the workflow calls back
    /// - Note: In the background this applies a UIKitPresenter, if you call launch on workflow directly you'll need to apply one yourself
    public func launchInto(_ workflow: AnyWorkflow, withLaunchStyle launchStyle: LaunchStyle.PresentationType = .default, onFinish: ((Any?) -> Void)? = nil) {
        workflow.applyOrchestrationResponder(UIKitPresenter(self, launchStyle: launchStyle))
        workflow.launch(withLaunchStyle: launchStyle.rawValue,
                        onFinish: onFinish)
        #if canImport(XCTest)
        NotificationCenter.default.post(name: .workflowLaunched, object: [
            "workflow": workflow,
            "launchFrom": self,
            "style": launchStyle,
            "onFinish": onFinish as Any
        ])
        #endif
    }
}

extension FlowRepresentable where Self: UIViewController {
    #warning("This should be updated. Probably needs abandon taken in and should also have a closure that is passed to abandon.")
    /**
     Ends the current workflow.

     - Note: `Workflow` does not call `onFinish`.
     */
    public func abandonWorkflow() {
        workflow?.abandon()
    }
}

extension Workflow {
    /// init: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistence: An `FlowPersistence`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public convenience init(_ type: F.Type,
                            presentationType: LaunchStyle.PresentationType,
                            flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) {
        self.init(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { _ in flowPersistence() })
    }
    /// init: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistence: A closure taking in the generic type from the `FlowRepresentable` and returning a `FlowPersistence`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
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

    /// init: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistence: A closure returning a `FlowPersistence`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public convenience init(_ type: F.Type,
                            presentationType: LaunchStyle.PresentationType,
                            flowPersistence: @escaping () -> FlowPersistence) where F.WorkflowInput == Never {
        self.init(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { _ in flowPersistence() })
    }

    /// init: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistence: A closure returning a `FlowPersistence`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public convenience init(_ type: F.Type,
                            presentationType: LaunchStyle.PresentationType,
                            flowPersistence: @escaping () -> FlowPersistence) where F.WorkflowInput == AnyWorkflow.PassedArgs {
        self.init(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { _ in flowPersistence() })
    }
}

extension Workflow where F.WorkflowOutput == Never {
    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistence: An `FlowPersistence`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                                   presentationType: LaunchStyle.PresentationType,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR> where FR.WorkflowInput == Never {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { _ in flowPersistence() })
        return wf
    }

    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistence: An `FlowPersistence`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                                   presentationType: LaunchStyle.PresentationType,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR>
    where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { _ in flowPersistence() })
        return wf
    }
}

extension Workflow {
    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistence: An `FlowPersistence`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                                   presentationType: LaunchStyle.PresentationType,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR> where F.WorkflowOutput == FR.WorkflowInput {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { _ in flowPersistence() })
        return wf
    }

    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistence: A closure taking in the generic type from the `FlowRepresentable` and returning a `FlowPersistence`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                                   presentationType: LaunchStyle.PresentationType,
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

    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistence: A closure returning a `FlowPersistence`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                                   presentationType: LaunchStyle.PresentationType,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR> where FR.WorkflowInput == Never {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { _ in flowPersistence() })
        return wf
    }

    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistence: A closure returning a `FlowPersistence`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
                                                   presentationType: LaunchStyle.PresentationType,
                                                   flowPersistence: @escaping @autoclosure () -> FlowPersistence = .default) -> Workflow<FR>
    where FR.WorkflowInput == AnyWorkflow.PassedArgs {
        let wf = Workflow<FR>(first)
        wf.append(FlowRepresentableMetadata(type,
                                            launchStyle: presentationType.rawValue) { _ in flowPersistence() })
        return wf
    }
}
