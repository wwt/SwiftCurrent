//
//  File.swift
//  
//
//  Created by thompsty on 7/12/21.
//

import Foundation
import SwiftUI
import SwiftCurrent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class WorkflowItem<F: FlowRepresentable & View> {
    public init(_: F.Type) { }
}
