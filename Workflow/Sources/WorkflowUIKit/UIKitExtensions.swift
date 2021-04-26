//
//  UIKitExtensions.swift
//  
//
//  Created by Tyler Thompson on 11/26/20.
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
    public func abandonWorkflow() {
        workflow?.abandon()
    }
}

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

extension Workflow where F.WorkflowOutput == Never {
    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistance: An `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
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
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
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

extension Workflow {
    /// thenPresent: A way of creating workflows with a fluent API. Useful for complex workflows with difficult requirements
    /// - Parameter type: A reference to the class used to create the workflow
    /// - Parameter presentationType: A `PresentationType` the flow representable should use while it's part of this workflow
    /// - Parameter flowPersistance: An `FlowPersistance`type representing how this item in the workflow should persist.
    /// - Returns: `Workflow`
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
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
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
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
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
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
    public func thenPresent<FR: FlowRepresentable>(_ type: FR.Type,
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