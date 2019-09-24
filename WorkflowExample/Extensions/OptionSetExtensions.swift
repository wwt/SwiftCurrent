//
//  OptionSetExtensions.swift
//  WorkflowExample
//
//  Created by Tyler Thompson on 9/24/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation

extension OptionSet where RawValue == Int {
    public func hasMultipleValues() -> Bool {
        guard rawValue > 2 else { return false }
        return !(ceil(log2(Double(rawValue))) == floor(log2(Double(rawValue))))
    }
}
