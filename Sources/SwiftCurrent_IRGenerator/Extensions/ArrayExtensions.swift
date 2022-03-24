//  swiftlint:disable:this file_name
//  ArrayExtensions.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 3/24/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation

extension Array {
    func appending(_ element: Element) -> [Element] {
        var copy = self
        copy.append(element)
        return copy
    }
}
