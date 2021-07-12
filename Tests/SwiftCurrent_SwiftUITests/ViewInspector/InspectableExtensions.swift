//
//  InspectableExtensions.swift
//  SwiftCurrent_SwiftUITests
//
//  Created by Tyler Thompson on 7/12/21.
//

import Foundation
import ViewInspector

@testable import SwiftCurrent_SwiftUI

#warning("Don't forget you need to make every view you want to test with ViewInspector Inspectable")
extension WorkflowView: Inspectable { }
