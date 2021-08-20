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
    private static var associatedKey = "_flowRepresentableMetadata_flowRepresentableTypeDescriptor_assoc_key"
    /// The type of `FlowRepresentable` that the metadata is about.
    public var flowRepresentableTypeDescriptor: String {
        get {
            guard let value = objc_getAssociatedObject(self, &Self.associatedKey) as? String else {
                return "ERROR: No flowRepresentableType found on \(self)"
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &Self.associatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
