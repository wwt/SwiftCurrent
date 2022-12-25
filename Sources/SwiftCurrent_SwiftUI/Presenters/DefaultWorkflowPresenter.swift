//
//  DefaultWorkflowPresenter.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 12/24/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
struct DefaultWorkflowPresenter {
    @ViewBuilder func present(content: some _WorkflowItemProtocol, nextView: (some _WorkflowItemProtocol)?, isActive: Binding<Bool>) -> some View {
        if isActive.wrappedValue, let nextView {
            nextView
        } else {
            content
        }
    }
}
