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
        XCTAssert(try shell("cd \(Self.packageSwiftDirectory.path) && swift build --target=SwiftCurrent_IRGenerator").contains("Build complete!"))
    }

    func testExample() throws {
        let source = """
        struct Foo: WorkflowDecodable { }
        """.literalized()

        let output = try shell("\(generatorCommand) \"\(source)\"")
        let IR = try JSONSerialization.jsonObject(with: XCTUnwrap(output.data(using: .utf8))) as? [[String: Any]]

        XCTAssertEqual(IR?.count, 1)
        XCTAssertEqual(IR?.first?["name"] as? String, "Foo")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

@discardableResult fileprivate func shell(_ command: String) throws -> String {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.executableURL = URL(fileURLWithPath: "/bin/zsh")

    try task.run()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!

    return output
}

extension Unicode.Scalar {
    var asciiEscaped: String { escaped(asASCII: true) }
}

extension StringProtocol {
    func literalized() -> String {
        unicodeScalars.map(\.asciiEscaped).joined()
    }
}
