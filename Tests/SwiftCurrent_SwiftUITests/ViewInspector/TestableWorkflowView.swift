//
//  TestableWorkflowView.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 1/15/23.
//  Copyright © 2023 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent_SwiftUI

@available(iOS 14.0, *)
func TestableWorkflowView<W: _WorkflowItemProtocol>(isLaunched: Binding<Bool> = .constant(true),
                                                    @TestableWorkflowBuilder content: () -> W) -> WorkflowView<W> {
    WorkflowView(isLaunched: isLaunched, content: content)
}

@available(iOS 14.0, *)
func TestableWorkflowView<W: _WorkflowItemProtocol, T>(isLaunched: Binding<Bool> = .constant(true),
                                                       launchingWith args: T,
                                                       @TestableWorkflowBuilder content: () -> W) -> WorkflowView<W> {
    WorkflowView(isLaunched: isLaunched, launchingWith: args, content: content)
}
