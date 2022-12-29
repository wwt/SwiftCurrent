//
//  File.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 12/24/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct WorkflowReader<Content: View>: View {
    @Environment(\.workflowProxy) private var proxy: WorkflowProxy

    @ViewBuilder private var content: (WorkflowProxy) -> Content

    public init(@ViewBuilder _ content: @escaping (WorkflowProxy) -> Content) {
        self.content = content
    }

    public var body: some View {
        content(proxy)
    }
}
