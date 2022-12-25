//
//  File.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 12/24/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent
import Combine

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public final class WorkflowProxy: ObservableObject {
    let proceedPublisher = PassthroughSubject<AnyWorkflow.PassedArgs, Never>()
    @Published var shouldLoad = true

    public func proceedInWorkflow() {
        proceedPublisher.send(.none)
    }

    public func proceedInWorkflow<T>(_ args: T) {
        proceedPublisher.send(.args(args))
    }

    public func proceedInWorkflow(_ args: AnyWorkflow.PassedArgs) {
        proceedPublisher.send(args)
    }
}
