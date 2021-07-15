//  swiftlint:disable:this file_name
//  AnyWorkflowExtensions.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 7/12/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftCurrent

extension AnyWorkflow {
    /// Called when the workflow should be terminated, and the app should return to the point before the workflow was launched.
    public func abandon() {
        orchestrationResponder?.abandon(self, onFinish: nil)
    }
}
