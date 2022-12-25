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
