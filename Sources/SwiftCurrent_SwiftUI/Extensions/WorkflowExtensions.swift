//  swiftlint:disable:this file_name
//  WorkflowExtensions.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 7/13/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftCurrent
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Workflow where F: FlowRepresentable & View {
    /// Called when the workflow should be terminated, and the app should return to the point before the workflow was launched.
    public func abandon() {
        AnyWorkflow(self).abandon()
    }
}
