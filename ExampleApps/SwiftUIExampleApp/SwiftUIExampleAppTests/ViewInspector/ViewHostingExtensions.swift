//  swiftlint:disable:this file_name
//  ViewHostingExtensions.swift
//  SwiftUIExampleAppTests
//
//  Created by Tyler Thompson on 7/15/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI
import ViewInspector

extension ViewHosting {
    static func loadView<V: View>(_ view: V) -> V {
        defer {
            Self.host(view: view)
        }
        return view
    }
}
