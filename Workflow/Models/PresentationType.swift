//
//  PresentationType.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/29/19.
//  Copyright © 2019 Tyler Tompson. All rights reserved.
//

import Foundation
import UIKit
/**
 PresentationType: An enum that indicates how FlowRepresentables should be presented
 
 ### Discussion:
 Mostly used when you tell a workflow to launch, or on the `FlowRepresentable` protocol if you have a view that preferrs to be launched with a certain style
 */
public enum PresentationType {
    /// navigationStack: Indicates a `FlowRepresentable` should be launched in a navigation stack of some kind (For example with UIKit this would use a UINavigationController)
    /// - Note: If no current navigation stack is available, one will be created
    case navigationStack
    /// modally: Indicates a `FlowRepresentable` should be launched modally
    case modally(ModalPresentationStyle = .automatic)
    /// default: Indicates a `FlowRepresentable` can be launched contextually
    /// - Note: If there's already a navigation stack, it will be used. Otherwise views will present modally
    case `default`
    
    public static var modally:PresentationType {
        return .modally()
    }
    
    public enum ModalPresentationStyle {
        case fullScreen
        case pageSheet
        case formSheet
        case currentContext
        case custom
        case overFullScreen
        case overCurrentContext
        case popover
        case none
        case automatic
    }
}

extension PresentationType: Equatable {
    public static func == (lhs:PresentationType, rhs:PresentationType) -> Bool {
        switch (lhs, rhs) {
            case (.navigationStack, .navigationStack): return true
            case (.default, .default): return true
            case (.modally(let pres1), .modally(let pres2)): return pres1 == pres2
            default: return false
        }
    }
}

/**
ViewPersistance: An enum that indicates how FlowRepresentables should be persist when in the view stack

### Discussion:
Used when you are creating a workflow
*/
public enum ViewPersistance {
    /// default: Indicates a `FlowRepresentable` in a `Workflow` should persist in the viewstack based on it's `shouldLoad` function
    case `default`
    /// default: Indicates a `FlowRepresentable` in a `Workflow` who's `shouldLoad` function returns false should still be in the viewstack so if a user navigates backwards it'll appear
    case hiddenInitially
    /// default: Indicates a `FlowRepresentable` in a `Workflow` who's `shouldLoad` function returns true should be removed from the viewstack after the user progresses past it
    case removedAfterProceeding
}
