//
//  WorkflowViewModel.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Megan Wiemer on 7/13/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftCurrent
import SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class WorkflowViewModel: ObservableObject {
    @Published var body = AnyView(EmptyView())
    @Published var erasedBody: Any?
    var isLaunched: Binding<Bool>?
    var onAbandon = [() -> Void]()
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowViewModel: OrchestrationResponder {
    func launch(to destination: AnyWorkflow.Element) {
        extractView(from: destination).model = self
        erasedBody = extractView(from: destination).erasedView
    }

    func proceed(to destination: AnyWorkflow.Element, from source: AnyWorkflow.Element) {
        extractView(from: destination).model = self
        erasedBody = extractView(from: destination).erasedView
    }

    func backUp(from source: AnyWorkflow.Element, to destination: AnyWorkflow.Element) {
        extractView(from: destination).model = self
        erasedBody = extractView(from: destination).erasedView
    }

    func abandon(_ workflow: AnyWorkflow, onFinish: (() -> Void)?) {
        isLaunched?.wrappedValue = false
        onAbandon.forEach { $0() }
    }

    func complete(_ workflow: AnyWorkflow, passedArgs: AnyWorkflow.PassedArgs, onFinish: ((AnyWorkflow.PassedArgs) -> Void)?) {
        if workflow.lastLoadedItem?.value.metadata.persistence == .removedAfterProceeding {
            if let lastPresentableItem = workflow.lastPresentableItem {
                extractView(from: lastPresentableItem).model = self
                erasedBody = extractView(from: lastPresentableItem).erasedView
            } else {
                isLaunched?.wrappedValue = false
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
