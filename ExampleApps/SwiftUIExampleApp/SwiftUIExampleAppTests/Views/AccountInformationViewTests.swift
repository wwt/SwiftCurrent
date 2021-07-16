//
//  AccountInformationViewTests.swift
//  SwiftUIExampleAppTests
//
//  Created by Tyler Thompson on 7/15/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import XCTest
import SwiftUI
import Swinject
import ViewInspector
import CodeScanner

@testable import SwiftCurrent_SwiftUI // 🤮 it sucks that this is necessary
@testable import SwiftUIExampleApp

final class AccountInformationViewTests: XCTestCase {
    func testAccountInformationView() throws {
        let exp = ViewHosting.loadView(AccountInformationView()).inspection.inspect { view in
            XCTAssertEqual(try view.find(ViewType.Text.self).string(), "Username: changeme")
            XCTAssertEqual(try view.find(ViewType.Button.self, traversal: .depthFirst).labelView().text().string(), "Change Username")
            XCTAssertEqual(try view.find(ViewType.Button.self).labelView().text().string(), "Change Password")
        }
        wait(for: [exp], timeout: 0.5)
    }
}
