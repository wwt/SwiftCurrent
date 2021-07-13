//
//  WorkflowViewModel.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Megan Wiemer on 7/13/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftCurrent
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class WorkflowViewModel: ObservableObject {
    @Published var body = AnyView(EmptyView())
    var isPresented: Binding<Bool>?
    var onAbandon = [() -> Void]()
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension WorkflowViewModel: OrchestrationResponder {
    func launch(to destination: AnyWorkflow.Element) {
        extractView(from: destination).model = self
    }

    func proceed(to destination: AnyWorkflow.Element, from source: AnyWorkflow.Element) {
        extractView(from: destination).model = self
    }

    func backUp(from source: AnyWorkflow.Element, to destination: AnyWorkflow.Element) {
        extractView(from: destination).model = self
    }

    func abandon(_ workflow: AnyWorkflow, onFinish: (() -> Void)?) {
        isPresented?.wrappedValue = false
        onAbandon.forEach { $0() }
    }

    func complete(_ workflow: AnyWorkflow, passedArgs: AnyWorkflow.PassedArgs, onFinish: ((AnyWorkflow.PassedArgs) -> Void)?) {
        if workflow.lastLoadedItem?.value.metadata.persistence == .removedAfterProceeding {
            if let lastPresentableItem = workflow.lastPresentableItem {
                extractView(from: lastPresentableItem).model = self
            } else {
                #warning("We are a little worried about animation here")
                body = AnyView(EmptyView())
            }
        }
        onFinish?(passedArgs)
    }

    private func extractView(from element: AnyWorkflow.Element) -> AnyFlowRepresentableView {
        guard let instance = element.value.instance as? AnyFlowRepresentableView else {
            fatalError("Could not cast \(String(describing: element.value.instance)) to expected type: AnyFlowRepresentableView")
        }
        return instance
    }
}

extension AnyWorkflow {
    fileprivate var lastLoadedItem: AnyWorkflow.Element? {
        last { $0.value.instance != nil }
    }

    fileprivate var lastPresentableItem: AnyWorkflow.Element? {
        last {
            $0.value.instance != nil && $0.value.metadata.persistence != .removedAfterProceeding
        }
    }
}
