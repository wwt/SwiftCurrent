//
//  AnyWorkflowItem.swift
//  SwiftCurrent
//
//  Created by Morgan Zellers on 11/2/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct AnyWorkflowItem: View {
    let inspection = Inspection<Self>()
    private let _body: AnyView

    public var body: some View {
        _body.onReceive(inspection.notice) { inspection.visit(self, $0) }
    }

    init<F, W, C>(view: WorkflowItem<F, W, C>) {
        _body = AnyView(view)
    }
}
