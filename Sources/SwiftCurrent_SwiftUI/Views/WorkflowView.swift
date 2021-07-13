//
//  WorkflowView.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 7/12/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI
import SwiftCurrent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct WorkflowView: View {
    @Binding public var isPresented: Bool

    public init(isPresented: Binding<Bool>) {
        _isPresented = .constant(false)
    }

    public var body: some View {
        EmptyView()
    }

    public func onFinish(_: () -> Void) -> Self {
        self
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension WorkflowView {
    public func thenProceed<FR: FlowRepresentable & View>(with _: WorkflowItem<FR>) -> WorkflowView {
        self // WRONG
    }
}
