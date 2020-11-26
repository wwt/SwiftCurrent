//
//  DIContainer.swift
//  Workflow
//
//  Created by Tyler Thompson on 12/17/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import Swinject
import Workflow

extension AnyWorkflow {
    static var defaultContainer = Container()
}

extension Workflow {
    public func dependencyInjectionSetup(setup: (Container) -> Void) -> Self {
        setup(Workflow.defaultContainer)
        return self
    }
}
