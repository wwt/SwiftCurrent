//  swiftlint:disable:this file_name
//  WorkflowExtensions.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 7/13/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftCurrent
import SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension Workflow where F: FlowRepresentable & View {
    /// Called when the workflow should be terminated, and the app should return to the point before the workflow was launched.
    public func abandon() {
        AnyWorkflow(self).abandon()
    }
}
