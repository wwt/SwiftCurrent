//
//  ViewHostingExtensions.swift
//  SwiftCurrent_SwiftUITests
//
//  Created by Tyler Thompson on 7/12/21.
//

import Foundation
import SwiftUI
import ViewInspector

#warning("These are not part of the library, take a look here so you understand what it does")
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension ViewHosting {
    static func loadView<V: View>(_ view: V) -> V {
        defer {
            Self.host(view: view)
        }
        return view
    }

    #warning("You may not need these, since you do not use environment objects")
    static func loadView<V: View, O: ObservableObject>(_ view: V, data: O) -> V {
        defer {
            Self.host(view: view.environmentObject(data))
        }
        return view
    }

    static func loadView<V: View, O: ObservableObject, E>(_ view: V, data: O, keyPath: WritableKeyPath<EnvironmentValues, E>, keyValue: E) -> V {
        defer {
            Self.host(view: view.environmentObject(data).environment(keyPath, keyValue))
        }
        return view
    }
}
