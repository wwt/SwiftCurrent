//
//  Presenter.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/26/19.
//  Copyright © 2019 Tyler Tompson. All rights reserved.
//

import Foundation

/**
 Presenter: Used in the event you want to create your own kind of presenter.
 
 ### Discussion:
 Hopefully the framework takes care of this for you, however there may be situations where you need to create your own presenter. A presenter fundamentally is just an object a Workflow reports to. It gets told when to launch a view, and where to launch it from. It also gets told when to abandon a particular workflow back to the beginning.
 */

public protocol Presenter: AnyPresenter {
    /// ViewType: The type your presenter deals with (e.g. UIViewController)
    associatedtype ViewType
    /// launch: A method to let the presenter know it needs to present a view
    /// - Parameter view: The view to show
    /// - Parameter root: The view that is currently visible
    /// - Parameter launchStyle: The preferred style to launch the view with see: `PresentationType`
    func launch(view:ViewType, from root:ViewType, withLaunchStyle launchStyle: PresentationType, animated:Bool)
    func destroy(_ view:ViewType)
}

public extension Presenter {
    func launch(view: Any?, from root: Any?, withLaunchStyle launchStyle: PresentationType, animated:Bool) {
        guard let v = view as? ViewType, let r = root as? ViewType else {
            fatalError("\(String(describing:Self.self)) is unaware of view type: \(String(describing: view)), expected view type: \(ViewType.self)")
        }
        launch(view: v, from: r, withLaunchStyle: launchStyle, animated: animated)
    }
    
    func destroy(_ view: Any?) {
        guard let v = view as? ViewType else {
            fatalError("\(String(describing:Self.self)) is unaware of view type: \(String(describing: view)), expected view type: \(ViewType.self)")
        }
        destroy(v)
    }
}
