//
//  WorkflowDecodableExtensionsTests.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Richard Gist on 12/29/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  

import XCTest
import SwiftUI

import SwiftCurrent
import SwiftCurrent_SwiftUI

@available(iOS 14.0, macOS 11, tvOS 14.0, watchOS 7.0, *)
class WorkflowDecodableExtensionsTests: XCTestCase {
    func testMetadataFactoryReturnsExtendedFlowRepresentableMetadataForViews() {
        struct FR1: View, FlowRepresentable, WorkflowDecodable {
            weak var _workflowPointer: AnyFlowRepresentable?
            var body: some View { EmptyView() }
        }

        let metadata = FR1.metadataFactory(launchStyle: .default) { _ in .default }
        let genericMetadata = (FR1.self as WorkflowDecodable.Type).metadataFactory(launchStyle: .default) { _ in .default }

        // ExtendedFlowRepresentableMetadata should be internal, but we must also test if the override is public.
        XCTAssert(type(of: metadata) != FlowRepresentableMetadata.self, "\(type(of: metadata)) should be overridden from type FlowRepresentableMetadata")
        XCTAssert(type(of: genericMetadata) != FlowRepresentableMetadata.self, "\(type(of: genericMetadata)) should be overridden from type FlowRepresentableMetadata")
    }

    func testDecodingLaunchStyleThatSwiftUIDoesNotRecognize_Throws() {
        struct FR1: View, FlowRepresentable, WorkflowDecodable {
            weak var _workflowPointer: AnyFlowRepresentable?
            var body: some View { EmptyView() }
        }

        XCTAssertThrowsError(try FR1.decodeFlowPersistence(named: "persistWhenSkipped"))
    }
}
