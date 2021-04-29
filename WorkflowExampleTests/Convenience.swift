//
//  Convenience.swift
//  WorkflowExampleTests
//
//  Created by Tyler Thompson on 9/25/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation

@testable import WorkflowExample

extension Address {
    init() {
        self.init(line1: "", line2: "", city: "", state: "", zip: "")
    }
}
