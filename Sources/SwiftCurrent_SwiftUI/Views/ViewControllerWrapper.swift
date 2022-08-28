//
//  ViewControllerWrapper.swift
//  SwiftCurrent_SwiftUI
//
//
//  Created by Tyler Thompson on 8/7/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

#if (os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)) && canImport(UIKit)
import SwiftUI
import SwiftCurrent

/// A wrapper for exposing `UIViewController`s that are `FlowRepresentable` to SwiftUI.
@available(iOS 14.0, macOS 11, tvOS 14.0, *)
public struct ViewControllerWrapper<F: FlowRepresentable & UIViewController>: View, UIViewControllerRepresentable, FlowRepresentable {
    public typealias UIViewControllerType = F
    public typealias WorkflowInput = F.WorkflowInput
    public typealias WorkflowOutput = F.WorkflowOutput

    public weak var _workflowPointer: AnyFlowRepresentable? {
        didSet {
            vc._workflowPointer = _workflowPointer
        }
    }

    private var vc: F

    @StateObject private var model: Model

    public init(with args: F.WorkflowInput) {
        let vc = F._factory(F.self, with: args)
        self.vc = vc
        _model = StateObject(wrappedValue: Model(vc: vc))
    }

    public init() {
        let vc = F._factory(F.self)
        self.vc = vc
        _model = StateObject(wrappedValue: Model(vc: vc))
    }

    public func makeUIViewController(context: Context) -> F {
        model.vc._workflowPointer = _workflowPointer
        return model.vc
    }

    public func updateUIViewController(_ uiViewController: F, context: Context) {
        model.vc._workflowPointer = _workflowPointer
    }

    public func shouldLoad() -> Bool { vc.shouldLoad() }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, *)
extension ViewControllerWrapper {
    @available(iOS 14.0, macOS 11, tvOS 14.0, *)
    final class Model: ObservableObject {
        var vc: F

        init(vc: F) {
            self.vc = vc
        }
    }
}
#endif
