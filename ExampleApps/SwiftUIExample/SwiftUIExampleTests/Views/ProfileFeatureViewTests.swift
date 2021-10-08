//
//  ProfileFeatureViewTests.swift
//  SwiftUIExampleTests
//
//  Created by Tyler Thompson on 7/15/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import SwiftUI
import Swinject
import ViewInspector

@testable import SwiftCurrent_SwiftUI // 🤮 it sucks that this is necessary
@testable import SwiftUIExample

final class ProfileFeatureViewTests: XCTestCase {
    func testProfileFeatureView() throws {
        let viewUnderTest = try ProfileFeatureView().inspect()
        XCTAssertEqual(try viewUnderTest.find(ViewType.Image.self).actualImage(), Image.wwtLogo.resizable())
        XCTAssertEqual(try viewUnderTest.find(ViewType.Section.self).header().text().string(), "Account Information")
        XCTAssertNoThrow(try viewUnderTest.find(ViewType.Section.self).find(AccountInformationView.self))
    }

    func testClearUserDefaultsButton() throws {
        addTeardownBlock { Container.default.removeAll() }
        let key = UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
        defaults.set(true, forKey: key)
        Container.default.register(UserDefaults.self) { _ in defaults }
        let viewUnderTest = try ProfileFeatureView().inspect()
        XCTAssertNoThrow(try viewUnderTest.find(ViewType.Image.self).callOnTapGesture())
        XCTAssertFalse(defaults.bool(forKey: key))
    }
}
