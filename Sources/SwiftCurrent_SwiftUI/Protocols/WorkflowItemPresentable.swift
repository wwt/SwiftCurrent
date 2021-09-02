//
//  WorkflowItemPresentable.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Morgan Zellers on 8/31/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftCurrent

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
protocol WorkflowItemPresentable {
    var workflowLaunchStyle: LaunchStyle.SwiftUI.PresentationType { get }
}
