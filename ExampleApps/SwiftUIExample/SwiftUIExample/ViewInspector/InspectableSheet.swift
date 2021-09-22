//  swiftlint:disable:this file_name
//  InspectableSheet.swift
//  SwiftUIExample
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
        modifier(InspectableSheetWithItem(item: item, onDismiss: onDismiss, popupBuilder: content))
    }
}

struct InspectableSheetWithItem<Item, Sheet>: ViewModifier where Item: Identifiable, Sheet: View {
    let item: Binding<Item?>
    let onDismiss: (() -> Void)?
    let popupBuilder: (Item) -> Sheet

    func body(content: Self.Content) -> some View {
        content.sheet(item: item, onDismiss: onDismiss, content: popupBuilder)
    }
}
