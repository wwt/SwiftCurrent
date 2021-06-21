//
//  ContentViewTests.swift
//  SwiftCurrentExample_SwiftUITests
//
//  Created by Richard Gist on 6/21/21.
//

import XCTest
import ViewInspector
import SwiftUI
import SwiftCurrent_SwiftUI
import SwiftCurrent

@testable import SwiftCurrentExample_SwiftUI

extension ContentView: Inspectable { }
extension SwiftUIResponder: Inspectable {}
extension SwiftUIResponder2: Inspectable {}
//extension FR1: Inspectable {}

class ContentViewTests: XCTestCase {
    func testViewHasString() throws {
        let view = ContentView()

        let stringValue = try view.inspect().text(0).string()

        XCTAssertEqual(stringValue, "Hello, world!")
    }

    func testViewHasResponder() throws {
//        XCTExpectFailure("As long as SwiftUIResponder is marked Inspectable, it will not block depth traversal to find text")

        let view = ContentView()

        let inspecty = try view.inspect()
        let texts = try inspecty.findAll(ViewType.Text.self)
        let everything = try inspecty.findAll(ViewType.AnyView.self)
        let responder = try inspecty.find(SwiftUIResponder.self)

        // CONTENT VIEW
        let skippy0 = try inspecty.find(relation: .child, traversal: .depthFirst, skipFound: 0, where: { thing in
            true
        })

        // TEXT
        let skippy1 = try inspecty.find(relation: .child, traversal: .depthFirst, skipFound: 1, where: { thing in
            true
        })

        let skippy1p5 = try inspecty.find(relation: .child, traversal: .depthFirst, skipFound: 1, where: { thing in
            try !thing.text().isHidden()
        })

        // RESPONDER
        let skippy2 = try inspecty.find(relation: .child, traversal: .depthFirst, skipFound: 2, where: { thing in
            true
        })

        let skippy3 = try inspecty.find(relation: .child, traversal: .depthFirst, skipFound: 3, where: { thing in
            true
        })

        XCTAssertEqual(texts.count, 2)
        XCTAssertEqual(try texts.last?.string(), "Hello, from SwiftUIResponder!")
    }

    func testResponder2CanWrap() throws {
        
    }
}
