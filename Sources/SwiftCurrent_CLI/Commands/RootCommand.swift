//
//  RootCommand.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 3/28/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import ArgumentParser

struct RootCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
            abstract: "A utility generating SwiftCurrent related files.",
            subcommands: [Generate.self])

    mutating func run() throws { }
}
