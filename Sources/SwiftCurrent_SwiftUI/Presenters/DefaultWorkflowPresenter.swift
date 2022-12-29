//
//  DefaultWorkflowPresenter.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 12/24/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI

/// The default presenter for workflows, it swaps the view contents.
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct DefaultWorkflowPresenter {
    /// presents either the current view (if active) or the next view, if not.
    @ViewBuilder public func present(content: some _WorkflowItemProtocol, nextView: (some _WorkflowItemProtocol)?, isActive: Binding<Bool>) -> some View {
        if isActive.wrappedValue, let nextView {
            nextView
        } else {
            content
        }
    }
}
