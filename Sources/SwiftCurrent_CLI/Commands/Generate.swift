//
//  GenerateIR.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 3/3/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//

import ArgumentParser

struct Generate: ParsableCommand {
    static var configuration = CommandConfiguration(
            abstract: "A utility generating SwiftCurrent related files.",
            subcommands: [IR.self])

    mutating func run() throws { }
}
