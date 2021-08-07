//
//  ViewControllerWrapper.swift
//  
//
//  Created by Tyler Thompson on 8/7/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI
import SwiftCurrent

#if os(iOS)
@available(iOS 14.0, *)
public struct ViewControllerWrapper<F: FlowRepresentable & UIViewController>: View, UIViewControllerRepresentable, FlowRepresentable {
    public typealias UIViewControllerType = F
    public typealias WorkflowInput = F.WorkflowInput
    public typealias WorkflowOutput = F.WorkflowOutput

    public weak var _workflowPointer: AnyFlowRepresentable?

    public static func _factory<FR>(_ type: FR.Type) -> FR where FR: FlowRepresentable {
        FR()
    }

    let args: WorkflowInput?
    public init(with args: F.WorkflowInput) {
        self.args = args
    }

    public init() { args = nil }

    public func makeUIViewController(context: Context) -> F {
        var vc: F = {
            if let args = args {
                return F._factory(F.self, with: args)
            } else {
                return F._factory(F.self)
            }
        }()
        vc._workflowPointer = _workflowPointer
        return vc
    }

    public func updateUIViewController(_ uiViewController: F, context: Context) { }
}
#endif
