//
//  WorkflowSwiftUITests.swift
//  WorkflowSwiftUITests
//
//  Created by Morgan Zellers on 5/19/21.
//

import XCTest
import SwiftUI
import ViewInspector

import Workflow
import WorkflowSwiftUI

class WorkflowSwiftUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        struct FR1: View, FlowRepresentable, Inspectable {
            var _workflowPointer: AnyFlowRepresentable?
            
            @State var calledShouldLoad = false
            
            var body: some View {
                Text("Because empty view does weird things")
            }
            
            func shouldLoad() -> Bool {
                calledShouldLoad = true
                return true
            }
        }
        
        let testObject = SwiftUIView(workflow: Workflow(FR1.self))
        
        let exp1 = testObject.inspect(inspection: { view in
            XCTAssertNotNil(try? view.find(FR1.self))
        })
        
        ViewHosting.host(view: testObject)
        wait(for: [exp1], timeout: 3.0)
    }
}
