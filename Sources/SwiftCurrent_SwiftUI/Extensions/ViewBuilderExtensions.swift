//
//  ViewBuilderExtensions.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Tyler Thompson on 9/13/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
func ViewBuilder<V: View>(@ViewBuilder builder: () -> V) -> some View { builder() }
