//
//  FlowRepresentableMetadata.swift
//  
//
//  Created by Tyler Thompson on 11/25/20.
//

import Foundation
public class FlowRepresentableMetaData {
    private(set) public var flowRepresentableType: AnyFlowRepresentable.Type
    private var flowPersistance: (Any?) -> FlowPersistance
    private(set) public var launchStyle: LaunchStyle
    private(set) public var persistance: FlowPersistance?

    func calculatePersistance(_ args: Any?) -> FlowPersistance {
        let val = flowPersistance(args)
        persistance = val
        return val
    }

    public init(_ flowRepresentableType: AnyFlowRepresentable.Type, launchStyle: LaunchStyle = .default, flowPersistance:@escaping (Any?) -> FlowPersistance) {
        self.flowRepresentableType = flowRepresentableType
        self.flowPersistance = flowPersistance
        self.launchStyle = launchStyle
    }

    public convenience init<FR>(with flowRepresentable: FR, launchStyle: LaunchStyle, persistance: FlowPersistance) where FR: AnyFlowRepresentable {
        self.init(FR.self, launchStyle: launchStyle, flowPersistance: { _ in persistance })
        self.persistance = persistance
    }
}
