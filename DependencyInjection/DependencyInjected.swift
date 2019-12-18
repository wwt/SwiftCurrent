//
//  DependencyInjected.swift
//  Workflow
//
//  Created by Tyler Thompson on 12/17/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import Swinject

@propertyWrapper
public struct DependencyInjected<Value> {
    let name:String?
    public init(wrappedValue value: Value?) {
        self.name = nil
    }
    public init(wrappedValue value: Value?, name:String?) {
        self.name = name
    }

    public lazy var wrappedValue: Value? = {
        Workflow.defaultContainer.resolve(Value.self, name: name)
    }()
}
