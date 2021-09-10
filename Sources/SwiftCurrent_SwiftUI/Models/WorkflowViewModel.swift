//
//  WorkflowViewModel.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Megan Wiemer on 7/13/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftCurrent
import SwiftUI
import Combine

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class WorkflowViewModel: ObservableObject {
    @Published var body: AnyWorkflow.Element?
    let onAbandonPublisher = PassthroughSubject<Void, Never>()
    let onFinishPublisher = CurrentValueSubject<AnyWorkflow.PassedArgs?, Never>(nil)
    let onBackUpPublisher = PassthroughSubject<AnyWorkflow.Element, Never>()

    @Binding var isLaunched: Bool
    private let launchArgs: AnyWorkflow.PassedArgs

    init(isLaunched: Binding<Bool>, launchArgs: AnyWorkflow.PassedArgs) {
        _isLaunched = isLaunched
        self.launchArgs = launchArgs
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowViewModel: OrchestrationResponder {
    func launch(to destination: AnyWorkflow.Element) {
        body = destination
    }

    func proceed(to destination: AnyWorkflow.Element, from source: AnyWorkflow.Element) {
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(1))) {
            self.body = destination
        }
        self.proceedCount += 1
    }

    func backUp(from source: AnyWorkflow.Element, to destination: AnyWorkflow.Element) {
        body = destination
        onBackUpPublisher.send(source)
    }

    func abandon(_ workflow: AnyWorkflow, onFinish: (() -> Void)?) {
        isLaunched = false
        body = nil
        onAbandonPublisher.send()
        if isLaunched == true {
            workflow.launch(withOrchestrationResponder: self, passedArgs: launchArgs)
        }
    }

    func complete(_ workflow: AnyWorkflow, passedArgs: AnyWorkflow.PassedArgs, onFinish: ((AnyWorkflow.PassedArgs) -> Void)?) {
        if workflow.lastLoadedItem?.value.metadata.persistence == .removedAfterProceeding {
            if let lastPresentableItem = workflow.lastPresentableItem {
                body = lastPresentableItem
            } else {
                isLaunched = false
            }
        }
        onFinishPublisher.send(passedArgs)
        onFinish?(passedArgs)
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
