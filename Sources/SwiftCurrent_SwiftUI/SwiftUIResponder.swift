//
//  SwiftUIResponder.swift
//  
//
//  Created by Richard Gist on 6/21/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI
import SwiftCurrent

public struct SwiftUIResponder: View {
    public init() {} // WHY?

    public var body: some View {
        Text("Hello, from SwiftUIResponder!")
    }
}

public struct SwiftUIResponder2: View, OrchestrationResponder {
    @ObservedObject var containedView = ContainedView()
    public init<F: FlowRepresentable>(workflow: Workflow<F>, onFinish: ((AnyWorkflow.PassedArgs) -> Void)? = nil) {
        workflow.launch(withOrchestrationResponder: self, onFinish: onFinish)
    }

    public var body: some View {
        containedView.view
    }

    public func launch(to: AnyWorkflow.Element) {
        guard let underlyingView = to.value.instance?.underlyingInstance as? AnyView else {
            fatalError("Underlying instance was not AnyView")
        }

        containedView.view = underlyingView
    }

    public func proceed(to: AnyWorkflow.Element, from: AnyWorkflow.Element) {
        guard let underlyingView = to.value.instance?.underlyingInstance as? AnyView else {
            fatalError("Underlying instance was not AnyView")
        }

        containedView.view = underlyingView
    }

    public func backUp(from: AnyWorkflow.Element, to: AnyWorkflow.Element) {
        guard let underlyingView = to.value.instance?.underlyingInstance as? AnyView else {
            fatalError("Underlying instance was not AnyView")
        }

        withAnimation {
            containedView.view = underlyingView
        }
    }

    public func abandon(_ workflow: AnyWorkflow, onFinish: (() -> Void)?) {
        abandon(workflow, animated: true, onFinish: onFinish)
    }

    func abandon(_ workflow: AnyWorkflow, animated: Bool, onFinish: (() -> Void)?) {
        if animated {
            withAnimation {
                containedView.view = AnyView(EmptyView())
            }
        } else {
            containedView.view = AnyView(EmptyView())
        }
    }

    public func complete(_ workflow: AnyWorkflow, passedArgs: AnyWorkflow.PassedArgs, onFinish: ((AnyWorkflow.PassedArgs) -> Void)?) {
        onFinish?(passedArgs)
    }
}

class ContainedView: ObservableObject {
    @Published var view = AnyView(EmptyView())
}

extension FlowRepresentable where Self: View {
    public var _workflowUnderlyingInstance: Any {
        get {
            AnyView(self)
        }
    }
}

