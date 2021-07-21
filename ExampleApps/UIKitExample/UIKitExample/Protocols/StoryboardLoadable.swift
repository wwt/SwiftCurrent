//
//  StoryboardLoadable.swift
//  UIKitExample
//
//  Created by Tyler Thompson on 9/24/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import UIKit

import SwiftCurrent_UIKit

extension StoryboardLoadable {
    static var storyboardId: String {
        String(describing: Self.self)
    }

    static var storyboard: UIStoryboard {
        Storyboard.main
    }
}
