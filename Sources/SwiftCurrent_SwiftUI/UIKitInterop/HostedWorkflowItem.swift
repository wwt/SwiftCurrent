//
//  HostedWorkflowItem.swift
//
//  Created by Tyler Thompson on 8/7/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

#if (os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)) && canImport(UIKit)
import UIKit
import SwiftUI
import SwiftCurrent

/**
 A wrapper around `UIHostingController` that is `FlowRepresentable`.

 ### Discussion
 `HostedWorkflowItem` is designed to be used in UIKit workflows that want to interoperate with SwiftUI. You do not need to inherit from this class, nor do you need to reference it outside of your workflow creation.

 #### Example
 ```swift
 struct SwiftUIView: View, FlowRepresentable {
     weak var _workflowPointer: AnyFlowRepresentable?

     var body: some View {
         Text("My View")
     }
 }

 // from the UIViewController launching the Workflow:
 launchInto(Workflow(FlowRepresentableViewController.self)
         .thenProceed(with: HostedWorkflowItem<SwiftUIView>.self))
 ```
 */
@available(iOS 14.0, macOS 11, tvOS 14.0, *)
public final class HostedWorkflowItem<Content: FlowRepresentable & View>: UIHostingController<Content>, FlowRepresentable {
    public typealias WorkflowInput = Content.WorkflowInput
    public typealias WorkflowOutput = Content.WorkflowOutput
    public var _workflowPointer: AnyFlowRepresentable? {
        get {
            rootView._workflowPointer
        }
        set {
            rootView._workflowPointer = newValue
        }
    }

    public init(with args: WorkflowInput) {
        super.init(rootView: Content._factory(Content.self, with: args))
    }

    public init() {
        super.init(rootView: Content._factory(Content.self))
    }

    @objc dynamic required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
}
#endif
