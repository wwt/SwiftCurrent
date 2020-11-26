//
//  NSObjectExtensions.swift
//  
//
//  Created by Tyler Thompson on 11/26/20.
//

import Foundation

extension NSObject {
    func copyObject<T: NSObject>() throws -> T? {
        let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? T
    }
}
