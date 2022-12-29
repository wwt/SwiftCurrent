//
//  ShouldLoadModifier.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 12/28/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct ShouldLoadModifier: ViewModifier {
    @State var shouldLoad: Bool
    @Environment(\.workflowProxy) var proxy

    public func body(content: Content) -> some View {
        content
            .onAppear {
                proxy.shouldLoad = shouldLoad
            }
    }
}
