//
//  AnyFlowRepresentableView.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Megan Wiemer on 7/13/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftCurrent
import SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
final class AnyFlowRepresentableView: AnyFlowRepresentable {
    var erasedView: Any = EmptyView()

    init<FR: FlowRepresentable & View>(type: FR.Type, args: AnyWorkflow.PassedArgs) {
        super.init(type, args: args)
        guard let instance = underlyingInstance as? FR else {
            fatalError("Could not cast \(String(describing: underlyingInstance)) to expected type: \(FR.self)")
        }
        erasedView = instance
    }

    func changeUnderlyingView<V: View>(to view: V) {
        erasedView = view
    }
}
