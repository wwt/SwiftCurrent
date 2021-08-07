//
//  HostedWorkflowItem.swift
//
//  Created by Tyler Thompson on 8/7/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

#if os(iOS) && canImport(UIKit)
import UIKit
import SwiftUI
import SwiftCurrent

@available(iOS 13.0, *)
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

    @objc dynamic required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
#endif
