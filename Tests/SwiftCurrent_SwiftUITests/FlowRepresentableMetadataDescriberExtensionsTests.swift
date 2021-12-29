//
//  File.swift
//  SwiftCurrent
//
//  Created by Richard Gist on 12/29/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

import XCTest
import SwiftUI

import SwiftCurrent
@testable import SwiftCurrent_SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
class FlowRepresentableMetadataDescriberExtensionsTests: XCTestCase {
    func testMetadataFactoryReturnsExtendedFlowRepresentableMetadataForViews() {
        struct FR1: View, FlowRepresentable, FlowRepresentableMetadataDescriber {
            weak var _workflowPointer: AnyFlowRepresentable?
            var body: some View { EmptyView() }
        }

        let metadata = FR1.metadataFactory()
        let genericMetadata = (FR1.self as FlowRepresentableMetadataDescriber.Type).metadataFactory()

        XCTAssertNotNil(metadata as? ExtendedFlowRepresentableMetadata, "\(metadata) should be of type ExtendedFlowRepresentableMetadata")
        XCTAssertNotNil(genericMetadata as? ExtendedFlowRepresentableMetadata, "\(metadata) should be of type ExtendedFlowRepresentableMetadata")
    }
}
