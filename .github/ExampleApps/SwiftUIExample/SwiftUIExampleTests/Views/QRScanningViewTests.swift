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
    func testQRScanningView() async throws {
        let view = try await QRScannerFeatureView().hostAndInspect(with: \.inspection)

        try await MainActor.run {
            XCTAssertEqual(try view.view(CodeScannerView.self).actualView().codeTypes, [.qr])
        }
    }

    func testQRScanningView_ShowsSheetWhenScanCompletes() async throws {
        let code = UUID().uuidString
        let view = try await QRScannerFeatureView().hostAndInspect(with: \.inspection)

        try await MainActor.run {
            XCTAssertNoThrow(try view.view(CodeScannerView.self).actualView().completion(.success(code)))
            XCTAssertEqual(try view.view(CodeScannerView.self).sheet().find(ViewType.Text.self).string(), "SCANNED DATA: \(code)")
            XCTAssertNoThrow(try view.view(CodeScannerView.self).sheet().dismiss())
            XCTAssertThrowsError(try view.view(CodeScannerView.self).sheet())
        }
    }
}
