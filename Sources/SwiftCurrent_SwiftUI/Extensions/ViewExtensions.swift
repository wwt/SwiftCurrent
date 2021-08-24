//  swiftlint:disable:this file_name
//  ViewExtensions.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Brian Lombardo on 8/24/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import SwiftCurrent
import SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension View {
    public func thenProceed<FR: FlowRepresentable>(with: FR.Type) -> WorkflowItem<FR, Never, FR> {
        WorkflowItem(FR.self)
    }

    public func thenProceed<FR: FlowRepresentable, F, W, C>(with: FR.Type, nextItem: () -> WorkflowItem<F, W, C>) -> WorkflowItem<FR, WorkflowItem<F, W, C>, FR> {
        WorkflowItem(FR.self) { nextItem() }
    }
}
