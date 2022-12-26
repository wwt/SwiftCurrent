//
//  ModalModifier.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 3/14/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
public struct WorkflowModalModifier<Wrapped: _WorkflowItemProtocol>: ViewModifier {
    @Binding var isPresented: Bool
    @State var modalStyle: LaunchStyle.SwiftUI.ModalPresentationStyle
    @State var destination: Wrapped?

    // Using a ViewBuilder here doesn't work due to a SwiftUI bug.
    // Short version, the only way the envrionment propagates correctly is if
    // You re-add whatever you want on `nextView` AND make sure you don't use
    // A BuildEither (if/else) block AND wrap it in something that displays, like a List.
    // This method circumvents the ViewBuilder using the `return` keyword.
    // Because the returns *must* be the same type, we're stuck with AnyView.
    public func body(content: Content) -> some View {
        switch modalStyle {
            case .sheet: content.testableSheet(isPresented: $isPresented) { destination }
            #if (os(iOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst))
            case .fullScreenCover: content.fullScreenCover(isPresented: $isPresented) { destination }
            #endif
        }
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
struct ModalModifier<V: View>: ViewModifier {
    @Binding var isPresented: Bool
    @State var modalStyle: LaunchStyle.SwiftUI.ModalPresentationStyle
    @State var destination: V

    func body(content: Self.Content) -> some View {
        switch modalStyle {
            case .sheet: content.testableSheet(isPresented: $isPresented) { destination }
            #if (os(iOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst))
            case .fullScreenCover: content.fullScreenCover(isPresented: $isPresented) { destination }
            #endif
        }
    }
}

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension View {
    func modal<V: View>(isPresented: Binding<Bool>, style: LaunchStyle.SwiftUI.ModalPresentationStyle, destination: V) -> some View {
        modifier(ModalModifier(isPresented: isPresented, modalStyle: style, destination: destination))
    }
}
