//
//  NavigationWorkflowPresenter.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 12/24/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI

/// Presenter for workflows; presents workflow items using a navigation link.
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct NavigationWorkflowPresenter {
    /// Present the next view with a navigation link; if active.
    @ViewBuilder public func present(content: some _WorkflowItemProtocol, nextView: (some _WorkflowItemProtocol)?, isActive: Binding<Bool>) -> some View {
        content
            .modifier(NavigationWorkflowLinkModifier(nextView: nextView, isActive: isActive))
    }
}
