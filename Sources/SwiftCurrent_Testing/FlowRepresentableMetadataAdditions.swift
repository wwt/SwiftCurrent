//  swiftlint:disable:this file_name
//  FlowRepresentableMetadataAdditions.swift
//  
//
//  Created by Tyler Thompson on 8/8/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import SwiftCurrent
extension FlowRepresentableMetadata {
    private static var associatedKey = "_flowRepresentableMetadata_flowRepresentableType_assoc_key"
    /// The type of `FlowRepresentable` that the metadata is about.
    public var flowRepresentableType: Any {
        get {
            guard let value = objc_getAssociatedObject(self, &Self.associatedKey) else {
                return "ERROR: No flowRepresentableType found on \(self)"
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &Self.associatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
