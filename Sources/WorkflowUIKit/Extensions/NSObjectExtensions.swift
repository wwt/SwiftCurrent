//  swiftlint:disable:this file_name
//  Reason: False positive until additional extensions are added.
//
//  NSObjectExtensions.swift
//  
//
//  Created by Tyler Thompson on 11/26/20.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation

extension NSObject {
    func copyObject<T: NSObject>() throws -> T? {
        let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? T
    }
}
