//
//  MockPresenter.swift
//  Workflow
//
//  Created by Tyler Thompson on 5/9/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
public class MockPresenter: Presenter {
    public var launchCalled = 0
    public var lastLaunchStyle: PresentationType?
    public var lastMetadata: FlowRepresentableMetaData?
    public var lastLaunchAnimated: Bool?
    public func launch(view: Any?, from root: Any?, withLaunchStyle launchStyle: PresentationType, metadata: FlowRepresentableMetaData, animated: Bool, completion: @escaping () -> Void) {
        launchCalled += 1
        lastLaunchStyle = launchStyle
        lastMetadata = metadata
        lastLaunchAnimated = animated
        
        completion()
    }
    
    public var abandonCalled = 0
    public var lastWorkflow:Workflow?
    public var lastAbandonAnimated:Bool?
    public func abandon(_ workflow: Workflow, animated: Bool, onFinish: (() -> Void)?) {
        abandonCalled += 1
        lastWorkflow = workflow
        lastAbandonAnimated = animated
        
        onFinish?()
    }
    
    required public init() { }
}
