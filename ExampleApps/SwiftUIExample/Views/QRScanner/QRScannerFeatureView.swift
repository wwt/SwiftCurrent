//
//  QRScannerFeatureView.swift
//  SwiftUIExample
//
//  Created by Tyler Thompson on 7/14/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import SwiftUI
import CodeScanner

struct QRScannerFeatureView: View {
    @State private var scannedCode: ScannedCode?

    let inspection = Inspection<Self>() // ViewInspector

    var body: some View {
        CodeScannerView(codeTypes: [.qr]) { result in
            if case .success(let scanContents) = result {
                scannedCode = ScannedCode(data: scanContents)
            }
        }
        .testableSheet(item: $scannedCode) { // swiftlint:disable:this multiline_arguments
            scannedCode = nil
        } content: { code in
            Text("SCANNED DATA: \(code.data)")
        }
        .onReceive(inspection.notice) { inspection.visit(self, $0) } // ViewInspector
    }
}

extension QRScannerFeatureView {
    private struct ScannedCode: Identifiable {
        let id = UUID()
        let data: String
    }
}
