//
//  SwiftCurrent_IRGeneratorTests.swift
//  SwiftCurrent
//
//  Created by Tyler Thompson on 3/3/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import Foundation
import XCTest

class SwiftCurrent_IRGeneratorTests: XCTestCase {
    static var packageSwiftDirectory: URL = {
        // ../../../ brings you to SwiftCurrent directory
        URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }()

    lazy var generatorCommand: String = {
        "\(Self.packageSwiftDirectory.path)/.build/*/debug/SwiftCurrent_IRGenerator"
    }()

    override class func setUp() {
        XCTAssertNoThrow(try shell("rm -rf \(Self.packageSwiftDirectory.path)/.build/*/debug"))
        XCTAssert(try shell("cd \(Self.packageSwiftDirectory.path) && swift build --product=SwiftCurrent_IRGenerator").contains("Build complete!"))
    }

    func testSingleDecodableStruct() throws {
        let source = """
        struct Foo: WorkflowDecodable { }
        """

        let output = try shell("\(generatorCommand) \"\(source)\"")
        let IR = try JSONDecoder().decode([IRType].self, from: XCTUnwrap(output.data(using: .utf8)))

        XCTAssertEqual(IR.count, 1)
        XCTAssertEqual(IR.first?.name, "Foo")
    }

    func testSingleDecodableClass() throws {
        let source = """
        class Foo: WorkflowDecodable { }
        """

        let output = try shell("\(generatorCommand) \"\(source)\"")
        let IR = try JSONDecoder().decode([IRType].self, from: XCTUnwrap(output.data(using: .utf8)))

        XCTAssertEqual(IR.count, 1)
        XCTAssertEqual(IR.first?.name, "Foo")
    }

    func testMultipleMixedStructsAndClasses() throws {
        let source = """
        class Foo: WorkflowDecodable { }
        struct Bar: WorkflowDecodable { }
        """

        let output = try shell("\(generatorCommand) \"\(source)\"")
        let IR = try JSONDecoder().decode([IRType].self, from: XCTUnwrap(output.data(using: .utf8)))
            .sorted { $0.name < $1.name }

        XCTAssertEqual(IR.count, 2)
        XCTAssertEqual(IR.first?.name, "Bar")
        XCTAssertEqual(IR.last?.name, "Foo")
    }

    func testPerformance_WithASingleType() throws {
        let source = """
        struct Foo: WorkflowDecodable { }
        """
        measure {
            _ = try? shell("\(generatorCommand) \"\(source)\"")
        }
    }

}

struct IRType: Decodable {
    let name: String
}

@discardableResult fileprivate func shell(_ command: String) throws -> String {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.executableURL = URL(fileURLWithPath: "/bin/zsh")

    try task.run()
    task.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!

    return output
}
