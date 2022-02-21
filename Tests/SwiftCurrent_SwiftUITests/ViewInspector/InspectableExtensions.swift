//
//  InspectableExtensions.swift
//  SwiftCurrent_SwiftUITests
//
//  Created by Tyler Thompson on 7/12/21.
//

import Foundation
import ViewInspector
import SwiftUI

@testable import SwiftCurrent_SwiftUI
import SwiftCurrent

// Don't forget you need to make every view you want to test with ViewInspector Inspectable
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowItem: Inspectable { }
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension WorkflowLauncher: Inspectable { }
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
typealias SpecializedWorkflowView<F: FlowRepresentable & View, W: View, C: View> = WorkflowView<WorkflowLauncher<WorkflowItem<F, W, C>>>
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension SpecializedWorkflowView: Inspectable { }
@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension ViewControllerWrapper: Inspectable { }

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension Inspection: InspectionEmissary where V: View { }

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension InspectableSheet: PopupPresenter { }
