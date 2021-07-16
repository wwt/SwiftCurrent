//  swiftlint:disable:this file_name
//  InspectableAlert.swift
//  SwiftUIExampleApp
//
//  Created by Tyler Thompson on 7/16/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI

// swiftlint:disable:next file_types_order
extension View {
    func testableAlert<Item>(item: Binding<Item?>, content: @escaping (Item) -> Alert) -> some View where Item: Identifiable {
        modifier(InspectableAlertWithItem(item: item, alertBuilder: content))
    }
}

struct InspectableAlertWithItem<Item: Identifiable>: ViewModifier {
    let item: Binding<Item?>
    let alertBuilder: (Item) -> Alert

    func body(content: Self.Content) -> some View {
        content.alert(item: item, content: alertBuilder)
    }
}
