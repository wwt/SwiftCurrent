//
//  ViewHostingExtensions.swift
//  SwiftCurrent_SwiftUITests
//
//  Created by Tyler Thompson on 7/12/21.
//

import Foundation
import SwiftUI
import ViewInspector

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension ViewHosting {
    static func loadView<V: View>(_ view: V) -> V {
        defer {
            Self.host(view: view)
        }
        return view
    }
}
