//  swiftlint:disable:this file_name
//  AnyWorkflowElementExtensions.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Tyler Thompson on 8/21/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftCurrent

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension AnyWorkflow.Element {
    func extractErasedView() -> Any? {
        guard let instance = value.instance else { return nil }
        guard let afrv = instance as? AnyFlowRepresentableView else {
            fatalError("Could not cast \(String(describing: value.instance)) to expected type: AnyFlowRepresentableView")
        }
        return afrv.erasedView
    }
}
