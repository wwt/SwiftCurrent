//
//  File.swift
//  
//
//  Created by Tyler Thompson on 11/24/20.
//

import Foundation
public protocol AnyOrchestrationResponder {
    func proceed(to: Any?, from: Any?, metadata: FlowRepresentableMetaData)
//    func launch(view:Any?, from root:Any?, withLaunchStyle launchStyle:PresentationType, metadata:FlowRepresentableMetaData, animated:Bool, completion:(() -> Void)?)
//    func abandon(_ workflow:AnyWorkflow, animated:Bool, onFinish:(() -> Void)?)
//    func destroy(_ view:Any?)
}
