//  swiftlint:disable:this file_name
//  NavigationWrapper.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Tyler Thompson on 8/27/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
extension View {
    // PROBLEM: SwiftUI has a bug if isActive is defaulted to true on NavLinks.
    // See details here: https://stackoverflow.com/questions/68365774/nested-navigationlinks-with-isactive-true-are-not-displaying-correctly
    func navLink<D: View>(to destination: D, isActive: Binding<Bool>) -> some View {
        background(
            List {
                NavigationLink(destination: destination,
                               isActive: isActive) { EmptyView() }
            }.opacity(0.01)
        )
    }
}
