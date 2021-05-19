//
//  SwiftUIView.swift
//  
//
//  Created by Morgan Zellers on 5/19/21.
// swiftlint:disable all

import SwiftUI
import Workflow

public struct SwiftUIView: View, OrchestrationResponder {
    @ObservedObject var viewy = Viewy()
    
    public var body: some View {
        viewy.viewy
    }
    
    public init<F: FlowRepresentable>(workflow: Workflow<F>) {
        workflow.launch(withOrchestrationResponder: self)
    }
    
    public func launch(to: AnyWorkflow.Element) {
        viewy.viewy = to.value.instance!.underlyingInstance as! AnyView
    }
    
    public func proceed(to: AnyWorkflow.Element, from: AnyWorkflow.Element) {
        viewy.viewy = to.value.instance?.underlyingInstance as! AnyView
    }
    
    public func backUp(from: AnyWorkflow.Element, to: AnyWorkflow.Element) {
        // Navigate backward
        // Takes me back to somewhere I was previously
        
        // Workflow() = FR1 -> FR2 -> FR3
        // FR1/FR3 -> FR1/FR2
    }
    
    //
    
    public func abandon(_ workflow: AnyWorkflow, onFinish: (() -> Void)?) {
        // End it now, and call onFinish
        // Exit and handle any finishing work
    }
    
}

class Viewy: ObservableObject {
    @Published var viewy = AnyView(EmptyView())
}

extension FlowRepresentable where Self: View {
    public var _workflowUnderlyingInstance: Any {
        get {
            AnyView(self)
        }
    }
}
