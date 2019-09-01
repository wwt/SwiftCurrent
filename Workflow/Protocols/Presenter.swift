//
//  Presenter.swift
//  Workflow
//
//  Created by Tyler Thompson on 8/26/19.
//  Copyright © 2019 TT. All rights reserved.
//

import Foundation

public protocol Presenter: AnyPresenter {
    associatedtype ViewType
    func launch(view:ViewType, from root:ViewType, withLaunchStyle launchStyle: PresentationType)
}

extension Presenter {
    public func launch(view: Any?, from root: Any?, withLaunchStyle launchStyle: PresentationType) {
        guard let v = view as? ViewType, let r = root as? ViewType else {
            fatalError("\(String(describing:Self.self)) is unaware of view type: \(view ?? "nil"), expected view type: \(ViewType.self)")
        }
        launch(view: v, from: r, withLaunchStyle: launchStyle)
    }
}
