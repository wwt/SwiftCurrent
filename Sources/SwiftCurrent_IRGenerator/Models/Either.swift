//
//  Either.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 3/3/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation
import ArgumentParser

enum Either<A, B> {
    case firstChoice(A)
    case secondChoice(B)
}

extension Either: ExpressibleByArgument where A: ExpressibleByArgument, B: ExpressibleByArgument {
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

extension Either: Decodable where A: Decodable, B: Decodable { }
