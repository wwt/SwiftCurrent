//
//  InspectableSheet.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Morgan Zellers on 8/31/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//
// swiftlint:disable file_types_order
import SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension View {
    func testableSheet<Sheet>(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Sheet
    ) -> some View where Sheet: View {
        modifier(InspectableSheet(isPresented: isPresented, onDismiss: onDismiss, content: content))
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
struct InspectableSheet<Sheet>: ViewModifier where Sheet: View {
    let isPresented: Binding<Bool>
    let onDismiss: (() -> Void)?
    let content: () -> Sheet
    let sheetBuilder: () -> Any

    init(isPresented: Binding<Bool>, onDismiss: (() -> Void)?, content: @escaping () -> Sheet) {
        self.isPresented = isPresented
        self.onDismiss = onDismiss
        self.content = content
        sheetBuilder = { content() as Any }
    }

    func body(content: Self.Content) -> some View {
        content.sheet(isPresented: isPresented, content: self.content)
    }
}
