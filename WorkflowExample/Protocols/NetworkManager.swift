//
//  NetworkManager.swift
//  WorkflowExample
//
//  Created by Tyler Thompson on 12/17/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation

protocol NetworkManager {
    func get(_ url:URL, completion:(Result<Any, Error>) -> Void)
}

class SomeNetworkManager: NetworkManager {
    func get(_ url: URL, completion: (Result<Any, Error>) -> Void) {
        completion(.success("data"))
    }
}
