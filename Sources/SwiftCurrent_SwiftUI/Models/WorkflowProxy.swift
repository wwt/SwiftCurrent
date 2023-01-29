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
    let backupPublisher = PassthroughSubject<Void, Never>()
    let abandonPublisher = PassthroughSubject<Void, Never>()
    let onFinishPublisher = CurrentValueSubject<AnyWorkflow.PassedArgs?, Never>(nil)

    @Published var shouldLoad = true
    var passedArgs: AnyWorkflow.PassedArgs?

    public func proceedInWorkflow() {
        proceedInWorkflow(.none)
    }

    public func proceedInWorkflow<T>(_ args: T) {
        proceedInWorkflow(.args(args))
    }

    public func proceedInWorkflow(_ args: AnyWorkflow.PassedArgs) {
        defer { passedArgs = args }
        proceedPublisher.send(args)
    }

    public func backUpInWorkflow() {
        backupPublisher.send()
    }

    public func abandonWorkflow() {
        abandonPublisher.send()
    }
}
