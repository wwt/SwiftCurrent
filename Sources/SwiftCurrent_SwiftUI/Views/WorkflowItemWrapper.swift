//
//  WorkflowItemWrapper.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 3/8/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct WorkflowItemWrapper<WI: _WorkflowItemProtocol, Wrapped: _WorkflowItemProtocol>: View, _WorkflowItemProtocol {
    public typealias F = WI.F // swiftlint:disable:this type_name

    public typealias Content = WI.Content

    @State private var content: WI
    @State private var wrapped: Wrapped?
    @State private var elementRef: AnyWorkflow.Element?
    @State private var isActive = false
    @EnvironmentObject private var model: WorkflowViewModel
    @EnvironmentObject private var launcher: Launcher
    @Environment(\.presentationMode) var presentation

    let inspection = Inspection<Self>()

    var launchStyle: LaunchStyle.SwiftUI.PresentationType {
        (content as? WorkflowItemPresentable)?.workflowLaunchStyle ?? .default
    }

    public var body: some View {
        ViewBuilder {
            if launchStyle == .navigationLink {
                content.navLink(to: nextView, isActive: $isActive)
            } else if case .modal(let modalStyle) = (wrapped as? WorkflowItemPresentable)?.workflowLaunchStyle {
                switch modalStyle {
                    case .sheet: content.testableSheet(isPresented: $isActive) { nextView }
                    #if (os(iOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst))
                    case .fullScreenCover: content.fullScreenCover(isPresented: $isActive) { nextView }
                    #endif
                }
            } else if launchStyle != .navigationLink, content.canDisplay(model.body) {
                content
            } else {
                nextView
            }
        }
        .onReceive(model.$body, perform: activateIfNeeded)
        .onReceive(model.$body, perform: proceedInWorkflow)
        .onReceive(model.onBackUpPublisher, perform: backUpInWorkflow)
        .onReceive(inspection.notice) { inspection.visit(self, $0) }
    }

    @ViewBuilder private var nextView: some View {
        wrapped?.environmentObject(model).environmentObject(launcher)
    }

    init(content: WI) where Wrapped == Never {
        _wrapped = State(initialValue: nil)
        _elementRef = State(initialValue: nil)
        _content = State(initialValue: content)
    }

    init(content: WI, wrapped: () -> Wrapped) {
        _wrapped = State(initialValue: wrapped())
        _elementRef = State(initialValue: nil)
        _content = State(initialValue: content)
        verifyWorkflowIsWellFormed(WI.F.self, Wrapped.F.self)
    }

    private func verifyWorkflowIsWellFormed<LHS: FlowRepresentable, RHS: FlowRepresentable>(_ lhs: LHS.Type, _ rhs: RHS.Type) {
        guard !(RHS.WorkflowInput.self is Never.Type), // an input type of `Never` indicates any arguments will simply be ignored
              !(RHS.WorkflowInput.self is AnyWorkflow.PassedArgs.Type), // an input type of `AnyWorkflow.PassedArgs` means either some value or no value can be passed
              !(LHS.WorkflowOutput.self is AnyWorkflow.PassedArgs.Type) else { return } // an output type of `AnyWorkflow.PassedArgs` can only be checked at runtime when the actual value is passed forward

        // trap if workflow is malformed (output does not match input)
        assert(LHS.WorkflowOutput.self is RHS.WorkflowInput.Type, "Workflow is malformed, expected output of: \(LHS.self) (\(LHS.WorkflowOutput.self)) to match input of: \(RHS.self) (\(RHS.WorkflowInput.self)")
    }

    public func canDisplay(_ element: AnyWorkflow.Element?) -> Bool {
        content.canDisplay(element) || wrapped?.canDisplay(element) == true
    }

    private func activateIfNeeded(element: AnyWorkflow.Element?) {
        if elementRef != nil, elementRef === element?.previouslyLoadedElement {
            isActive = true
        }
    }

    private func backUpInWorkflow(element: AnyWorkflow.Element?) {
        // We have found no satisfactory way to test this...we haven't even really found unsatisfactory ways to test it.
        // See: https://github.com/nalexn/ViewInspector/issues/131
        if elementRef === element {
            presentation.wrappedValue.dismiss()
        }
    }

    private func proceedInWorkflow(element: AnyWorkflow.Element?) {
        if element?.extractErasedView() as? WI.Content != nil, elementRef === element || elementRef == nil {
            elementRef = element
        }
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowItemWrapper: WorkflowModifier {
    func modify(workflow: AnyWorkflow) {
        (content as? WorkflowModifier)?.modify(workflow: workflow)
        (wrapped as? WorkflowModifier)?.modify(workflow: workflow)
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowItemWrapper: WorkflowItemPresentable where WI: WorkflowItemPresentable {
    var workflowLaunchStyle: LaunchStyle.SwiftUI.PresentationType {
        content.workflowLaunchStyle
    }
}
