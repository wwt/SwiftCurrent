//  swiftlint:disable:this file_name
//  InspectableExtensions.swift
//  SwiftUIExampleAppTests
//
//  Created by Tyler Thompson on 7/15/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import ViewInspector
import SwiftUI
import CodeScanner

@testable import SwiftUIExampleApp
@testable import SwiftCurrent_SwiftUI

// Don't forget you need to make every view you want to test with ViewInspector Inspectable
extension ProfileFeatureOnboardingView: Inspectable { }
extension QRScannerFeatureOnboardingView: Inspectable { }
extension MapFeatureOnboardingView: Inspectable { }
extension MapFeatureView: Inspectable { }
extension WorkflowView: Inspectable { }
extension ChangeUsernameView: Inspectable { }
extension ChangePasswordView: Inspectable { }
extension QRScannerFeatureView: Inspectable { }
extension ProfileFeatureView: Inspectable { }
extension ContentView: Inspectable { }
extension AccountInformationView: Inspectable { }
extension CardInformationView: Inspectable { }
extension CodeScannerView: Inspectable { }
extension MFAuthenticationView: Inspectable { }

extension SwiftUIExampleApp.Inspection: InspectionEmissary where V: View { }
extension SwiftCurrent_SwiftUI.Inspection: InspectionEmissary where V: View { }
extension InspectableSheetWithItem: SheetItemProvider { }
