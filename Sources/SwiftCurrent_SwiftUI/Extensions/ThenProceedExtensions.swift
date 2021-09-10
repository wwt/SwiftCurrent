//  swiftlint:disable:this file_name
//  ThenProceedExtensions.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Brian Lombardo on 8/24/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation
import SwiftCurrent
import SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension View {
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter with: a `FlowRepresentable` type that should be presented.
     - Returns: a new `WorkflowItem` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable>(with: FR.Type) -> WorkflowItem<FR, Never, FR> {
        WorkflowItem(FR.self)
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter with: a `FlowRepresentable` type that should be presented.
     - Parameter nextItem: a closure returning the next item in the `Workflow`.
     - Returns: a new `WorkflowItem` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, F, W, C>(with: FR.Type, nextItem: () -> WorkflowItem<F, W, C>) -> WorkflowItem<FR, WorkflowItem<F, W, C>, FR> where FR.WorkflowOutput == F.WorkflowInput {
        WorkflowItem(FR.self) { nextItem() }
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter with: a `FlowRepresentable` type that should be presented.
     - Parameter nextItem: a closure returning the next item in the `Workflow`.
     - Returns: a new `WorkflowItem` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, F, W, C>(with: FR.Type, nextItem: () -> WorkflowItem<F, W, C>) -> WorkflowItem<FR, WorkflowItem<F, W, C>, FR> where F.WorkflowInput == Never {
        WorkflowItem(FR.self) { nextItem() }
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter with: a `FlowRepresentable` type that should be presented.
     - Parameter nextItem: a closure returning the next item in the `Workflow`.
     - Returns: a new `WorkflowItem` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, F, W, C>(with: FR.Type, nextItem: () -> WorkflowItem<F, W, C>) -> WorkflowItem<FR, WorkflowItem<F, W, C>, FR> where F.WorkflowInput == AnyWorkflow.PassedArgs {
        WorkflowItem(FR.self) { nextItem() }
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter with: a `FlowRepresentable` type that should be presented.
     - Parameter nextItem: a closure returning the next item in the `Workflow`.
     - Returns: a new `WorkflowItem` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, F, W, C>(with: FR.Type, nextItem: () -> WorkflowItem<F, W, C>) -> WorkflowItem<FR, WorkflowItem<F, W, C>, FR> where FR.WorkflowOutput == AnyWorkflow.PassedArgs, F.WorkflowInput == AnyWorkflow.PassedArgs {
        WorkflowItem(FR.self) { nextItem() }
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter with: a `FlowRepresentable` type that should be presented.
     - Parameter nextItem: a closure returning the next item in the `Workflow`.
     - Returns: a new `WorkflowItem` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, F, W, C>(with: FR.Type, nextItem: () -> WorkflowItem<F, W, C>) -> WorkflowItem<FR, WorkflowItem<F, W, C>, FR> where FR.WorkflowOutput == AnyWorkflow.PassedArgs, F.WorkflowInput == Never {
        WorkflowItem(FR.self) { nextItem() }
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter with: a `FlowRepresentable` type that should be presented.
     - Parameter nextItem: a closure returning the next item in the `Workflow`.
     - Returns: a new `WorkflowItem` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, F, W, C>(with: FR.Type, nextItem: () -> WorkflowItem<F, W, C>) -> WorkflowItem<FR, WorkflowItem<F, W, C>, FR> where FR.WorkflowOutput == AnyWorkflow.PassedArgs {
        WorkflowItem(FR.self) { nextItem() }
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter with: a `FlowRepresentable` type that should be presented.
     - Parameter nextItem: a closure returning the next item in the `Workflow`.
     - Returns: a new `WorkflowItem` with the additional `FlowRepresentable` item.
     */
    public func thenProceed<FR: FlowRepresentable, F, W, C>(with: FR.Type, nextItem: () -> WorkflowItem<F, W, C>) -> WorkflowItem<FR, WorkflowItem<F, W, C>, FR> where FR.WorkflowOutput == Never, F.WorkflowInput == Never {
        WorkflowItem(FR.self) { nextItem() }
    }

    #if (os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)) && canImport(UIKit)
    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter with: a `FlowRepresentable` type that should be presented.
     - Returns: a new `WorkflowItem` with the additional `FlowRepresentable` item.
     */
    @available(iOS 14.0, macOS 11, tvOS 14.0, *)
    public func thenProceed<VC: FlowRepresentable & UIViewController>(with: VC.Type) -> WorkflowItem<ViewControllerWrapper<VC>, Never, ViewControllerWrapper<VC>> {
        WorkflowItem(VC.self)
    }

    /**
     Adds an item to the workflow; enforces the `FlowRepresentable.WorkflowOutput` of the previous item matches the args that will be passed forward.
     - Parameter with: a `FlowRepresentable` type that should be presented.
     - Parameter nextItem: a closure returning the next item in the `Workflow`.
     - Returns: a new `WorkflowItem` with the additional `FlowRepresentable` item.
     */
    @available(iOS 14.0, macOS 11, tvOS 14.0, *)
    public func thenProceed<VC: FlowRepresentable & UIViewController, F, W, C>(with: VC.Type, nextItem: () -> WorkflowItem<F, W, C>) -> WorkflowItem<ViewControllerWrapper<VC>, WorkflowItem<F, W, C>, ViewControllerWrapper<VC>> {
        WorkflowItem(VC.self) { nextItem() }
    }
    #endif
}
