//
//  ExtendedFlowRepresentableMetadata.swift
//  SwiftCurrent
//
//  Created by Morgan Zellers on 11/2/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent

//@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
//class ExtendedFlowRepresentableMetadata: FlowRepresentableMetadata {
//    private(set) var workflowItemFactory: (AnyWorkflowItem?) -> AnyWorkflowItem
//
//    init<FR: FlowRepresentable & View>(flowRepresentableType: FR.Type,
//                                       launchStyle: LaunchStyle = .default,
//                                       flowPersistence: @escaping (AnyWorkflow.PassedArgs) -> FlowPersistence = { _ in .default },
//                                       flowRepresentableFactory: @escaping (AnyWorkflow.PassedArgs) -> AnyFlowRepresentable) {
//        func createWorkflowItem() -> WorkflowItem<FR, FR> {
//            WorkflowItem(FR.self)
//                .presentationType(.init(rawValue: launchStyle) ?? .default)
//                .settingPersistence(flowPersistence)
//        }
//
//        workflowItemFactory = {
//            guard let wrappedWorkflowItem = $0 else { return AnyWorkflowItem(view: WorkflowItemWrapper(content: createWorkflowItem())) }
//            return AnyWorkflowItem(view: WorkflowItemWrapper(content: createWorkflowItem()) { wrappedWorkflowItem })
//        }
//
//        super.init(flowRepresentableType, launchStyle: launchStyle, flowPersistence: flowPersistence, flowRepresentableFactory: flowRepresentableFactory)
//    }
//
//    init<FR: FlowRepresentable & View>(flowRepresentableType: FR.Type,
//                                       launchStyle: LaunchStyle = .default,
//                                       flowPersistence: @escaping (AnyWorkflow.PassedArgs) -> FlowPersistence = { _ in .default }) {
//        func createWorkflowItem() -> WorkflowItem<FR, FR> {
//            WorkflowItem(FR.self)
//                .presentationType(.init(rawValue: launchStyle) ?? .default)
//                .settingPersistence(flowPersistence)
//        }
//
//        workflowItemFactory = {
//            guard let wrappedWorkflowItem = $0 else { return AnyWorkflowItem(view: WorkflowItemWrapper(content: createWorkflowItem())) }
//            return AnyWorkflowItem(view: WorkflowItemWrapper(content: createWorkflowItem()) { wrappedWorkflowItem })
//        }
//
//        super.init(flowRepresentableType, launchStyle: launchStyle, flowPersistence: flowPersistence) { args in
//            AnyFlowRepresentableView(type: FR.self, args: args)
//        }
//    }
//}
