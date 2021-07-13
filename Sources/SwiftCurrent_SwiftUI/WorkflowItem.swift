//
//  WorkflowItem.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 7/12/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftCurrent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class WorkflowItem<F: FlowRepresentable & View> {
    public init(_: F.Type) { }
}
