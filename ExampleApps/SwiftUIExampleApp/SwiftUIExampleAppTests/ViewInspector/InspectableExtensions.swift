//  swiftlint:disable:this file_name
//  InspectableExtensions.swift
//  SwiftUIExampleAppTests
//
//  Created by Tyler Thompson on 7/15/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import ViewInspector
import SwiftUI

@testable import SwiftUIExampleApp
@testable import SwiftCurrent_SwiftUI

// Don't forget you need to make every view you want to test with ViewInspector Inspectable
extension ProfileFeatureOnboardingView: Inspectable { }
extension WorkflowView: Inspectable { }

extension SwiftUIExampleApp.Inspection: InspectionEmissary where V: View { }
extension SwiftCurrent_SwiftUI.Inspection: InspectionEmissary where V: View { }
