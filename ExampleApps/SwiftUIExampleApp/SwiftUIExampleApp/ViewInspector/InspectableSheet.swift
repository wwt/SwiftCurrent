//  swiftlint:disable:this file_name
//  InspectableSheet.swift
//  SwiftUIExampleApp
//
//  Created by Tyler Thompson on 7/15/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI

// swiftlint:disable:next file_types_order
extension View {
    func testableSheet<Item, Sheet>(item: Binding<Item?>,
                                    onDismiss: (() -> Void)? = nil,
                                    content: @escaping (Item) -> Sheet) -> some View where Item: Identifiable, Sheet: View {
        modifier(InspectableSheetWithItem(item: item, onDismiss: onDismiss, content: content))
    }
}

struct InspectableSheetWithItem<Item, Sheet>: ViewModifier where Item: Identifiable, Sheet: View {
    let item: Binding<Item?>
    let onDismiss: (() -> Void)?
    let content: (Item) -> Sheet
    let sheetBuilder: (Item) -> Any

    init(item: Binding<Item?>, onDismiss: (() -> Void)?, content: @escaping (Item) -> Sheet) {
        self.item = item
        self.onDismiss = onDismiss
        self.content = content
        self.sheetBuilder = { content($0) as Any }
    }

    func body(content: Self.Content) -> some View {
        content.sheet(item: item, onDismiss: onDismiss, content: self.content)
    }
}
