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
    private(set) public var presentationType: LaunchStyle
    private(set) public var persistance: FlowPersistance?

    func calculatePersistance(_ args: Any?) -> FlowPersistance {
        let val = flowPersistance(args)
        persistance = val
        return val
    }

    public init(_ flowRepresentableType: AnyFlowRepresentable.Type, presentationType: LaunchStyle = .default, flowPersistance:@escaping (Any?) -> FlowPersistance) {
        self.flowRepresentableType = flowRepresentableType
        self.flowPersistance = flowPersistance
        self.presentationType = presentationType
    }

    public convenience init<FR>(with flowRepresentable: FR, presentationType: LaunchStyle, persistance: FlowPersistance) where FR: AnyFlowRepresentable {
        self.init(FR.self, presentationType: presentationType, flowPersistance: { _ in persistance })
        self.persistance = persistance
    }
}
