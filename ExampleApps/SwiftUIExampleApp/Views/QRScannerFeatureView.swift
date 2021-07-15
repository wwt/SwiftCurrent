//
//  QRScannerFeatureView.swift
//  SwiftUIExampleApp
//
//  Created by Tyler Thompson on 7/14/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import SwiftUI
import SwiftCurrent
import CodeScanner

struct QRScannerFeatureView: View, FlowRepresentable {
    @State private var scannedCode: ScannedCode?

    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        CodeScannerView(codeTypes: [.qr]) { result in
            if case .success(let scanContents) = result {
                scannedCode = ScannedCode(data: scanContents)
            }
        }
        .sheet(item: $scannedCode) { // swiftlint:disable:this multiline_arguments
            scannedCode = nil
        } content: { code in
            Text("SCANNED DATA: \(code.data)")
        }
    }
}

extension QRScannerFeatureView {
    private struct ScannedCode: Identifiable {
        let id = UUID()
        let data: String
    }
}
