//
//  QRScanningViewTests.swift
//  SwiftUIExampleTests
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
@testable import SwiftUIExample

final class QRScanningViewTests: XCTestCase {
    func testQRScanningView() throws {
        let exp = ViewHosting.loadView(QRScannerFeatureView()).inspection.inspect { viewUnderTest in
            XCTAssertEqual(try viewUnderTest.view(CodeScannerView.self).actualView().codeTypes, [.qr])
        }
        wait(for: [exp], timeout: TestConstant.timeout)
    }

    func testQRScanningView_ShowsSheetWhenScanCompletes() throws {
        let code = UUID().uuidString
        let exp = ViewHosting.loadView(QRScannerFeatureView()).inspection.inspect { viewUnderTest in
            XCTAssertNoThrow(try viewUnderTest.view(CodeScannerView.self).actualView().completion(.success(code)))
            XCTAssertEqual(try viewUnderTest.view(CodeScannerView.self).sheet().find(ViewType.Text.self).string(), "SCANNED DATA: \(code)")
            XCTAssertNoThrow(try viewUnderTest.view(CodeScannerView.self).sheet().dismiss())
            XCTAssertThrowsError(try viewUnderTest.view(CodeScannerView.self).sheet())
        }
        wait(for: [exp], timeout: TestConstant.timeout)
    }
}
