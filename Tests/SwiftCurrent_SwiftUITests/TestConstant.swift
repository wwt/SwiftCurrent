//
//  File.swift
//  
//
//  Created by Richard Gist on 7/27/21.
//

import Foundation

enum TestConstant {
    static var timeout: TimeInterval {
//        5.0 // Pipeline
        return 0.1; #warning("Local timeout should not be checked in")
    }
}
