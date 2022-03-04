//
//  Either.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 3/3/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation
import ArgumentParser

enum Either<A: ExpressibleByArgument & Decodable, B: ExpressibleByArgument & Decodable>: ExpressibleByArgument, Decodable {
    case firstChoice(A)
    case secondChoice(B)

    init?(argument: String) {
        if let a = A(argument: argument) {
            self = .firstChoice(a)
        } else if let b = B(argument: argument) {
            self = .secondChoice(b)
        } else {
            return nil
        }
    }
}
