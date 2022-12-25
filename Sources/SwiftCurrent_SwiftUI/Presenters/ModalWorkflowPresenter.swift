//
//  ModalWorkflowPresenter.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 12/25/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct ModalWorkflowPresenter {
    @ViewBuilder public func present(content: some _WorkflowItemProtocol, nextView: (some _WorkflowItemProtocol)?, isActive: Binding<Bool>, style: LaunchStyle.SwiftUI.ModalPresentationStyle) -> some View {
        switch style {
            case .sheet:
                content.sheet(isPresented: isActive) { nextView }
            case .fullScreenCover:
                content.fullScreenCover(isPresented: isActive) { nextView }
        }
    }
}
