//  swiftlint:disable:this file_name
//  ContainerExtensions.swift
//  SwiftUIExample
//
//  Created by Tyler Thompson on 7/15/21.
//
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.

import Swinject
import Foundation

extension Container {
    static let `default` = Container()
}

extension UserDefaults {
    static var fromDI: UserDefaults? { Container.default.resolve(Self.self) }
}
