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

#warning("Don't forget you need to make every view you want to test with ViewInspector Inspectable")
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension WorkflowView: Inspectable { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Inspection: InspectionEmissary where V: View { }
