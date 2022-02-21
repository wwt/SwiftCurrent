//  swiftlint:disable:this file_name
//  InspectableExtensions.swift
//  SwiftUIExampleTests
//
//  Created by Tyler Thompson on 7/15/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import ViewInspector
import SwiftUI
import CodeScanner

@testable import SwiftUIExample
@testable import SwiftCurrent_SwiftUI

// Don't forget you need to make every view you want to test with ViewInspector Inspectable
extension SwiftCurrentOnboarding: Inspectable { }
extension GenericOnboardingView: Inspectable { }
extension ProfileFeatureOnboardingView: Inspectable { }
extension QRScannerFeatureOnboardingView: Inspectable { }
extension MapFeatureOnboardingView: Inspectable { }
extension MapFeatureView: Inspectable { }
extension WorkflowItem: Inspectable { }
extension WorkflowLauncher: Inspectable { }
extension WorkflowView: Inspectable { }
extension ChangeEmailView: Inspectable { }
extension ChangePasswordView: Inspectable { }
extension QRScannerFeatureView: Inspectable { }
extension ProfileFeatureView: Inspectable { }
extension ContentView: Inspectable { }
extension AccountInformationView: Inspectable { }
extension CodeScannerView: Inspectable { }
extension MFAView: Inspectable { }
extension ViewControllerWrapper: Inspectable { }
extension TermsAndConditions: Inspectable { }
extension SignUp: Inspectable { }
extension LoginView: Inspectable { }

extension PrimaryButton: Inspectable { }
extension SecondaryButton: Inspectable { }
extension PrimaryTextField: Inspectable { }
extension PasswordField: Inspectable { }

extension SwiftUIExample.Inspection: InspectionEmissary where V: View { }
extension SwiftCurrent_SwiftUI.Inspection: InspectionEmissary where V: View { }
extension InspectableSheetWithItem: ItemPopupPresenter { }
extension InspectableAlertWithItem: ItemPopupPresenter { }
