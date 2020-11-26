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

public extension UIViewController {
    ///launchInto: When using UIKit this is how you launch a workflow
    /// - Parameter workflow: `Workflow` to launch
    /// - Parameter args: Args to pass to the first `FlowRepresentable`
    /// - Parameter launchStyle: The `PresentationType` used to launch the workflow
    /// - Parameter onFinish: A callback that is called when the last item in the workflow calls back
    /// - Note: In the background this applies a UIKitPresenter, if you call launch on workflow directly you'll need to apply one yourself
    func launchInto(_ workflow: AnyWorkflow, args: Any? = nil, withLaunchStyle launchStyle: LaunchStyle.PresentationType = .default, onFinish: ((Any?) -> Void)? = nil) {
        workflow.applyOrchestrationResponder(UIKitPresenter(self, launchStyle: launchStyle))
        _ = workflow.launch(with: args,
                            withLaunchStyle: launchStyle.rawValue,
                            onFinish: onFinish)?.value as? UIViewController
        #if DEBUG
        if NSClassFromString("XCTest") != nil {
            NotificationCenter.default.post(name: .workflowLaunched, object: [
                "workflow": workflow,
                "launchFrom": self,
                "args": args,
                "style": launchStyle,
                "onFinish": onFinish
            ])
        }
        #endif
    }
}

public extension FlowRepresentable where Self: UIViewController {
    func abandonWorkflow() {
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
                                            presentationType: presentationType.rawValue,
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
                                            presentationType: presentationType.rawValue,
                                            flowPersistance: { data in
                                                guard let cast = data as? F.WorkflowInput else { return .default }
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
                                            presentationType: presentationType.rawValue,
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
                                            presentationType: presentationType.rawValue,
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
                                            presentationType: presentationType.rawValue,
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
                                            presentationType: presentationType.rawValue,
                                            flowPersistance: { data in
                                                guard let cast = data as? FR.WorkflowInput else { return .default }
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
                                            presentationType: presentationType.rawValue,
                                            flowPersistance: { _ in
                                                return flowPersistance()
                                            }))
        return wf
    }
}
