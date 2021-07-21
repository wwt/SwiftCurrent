//
//  DependencyInjected.swift
//  SwiftUIExample
//
//  Created by Tyler Thompson on 7/15/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import Swinject

@propertyWrapper
struct DependencyInjected<Value> {
    let nameGetter: (() -> String?)
    let containerGetter: () -> Container

    init(container: @escaping @autoclosure () -> Container = Container.default,
         name: @escaping @autoclosure (() -> String?) = nil) {
        self.nameGetter = name
        self.containerGetter = container
    }

    lazy var wrappedValue: Value? = {
        containerGetter().resolve(Value.self, name: nameGetter())
    }()
}
