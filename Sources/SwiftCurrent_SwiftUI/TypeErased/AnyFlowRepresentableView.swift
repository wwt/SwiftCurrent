//
//  AnyFlowRepresentableView.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Megan Wiemer on 7/13/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftCurrent
import SwiftUI

final class AnyFlowRepresentableView: AnyFlowRepresentable {
    var model: WorkflowViewModel? {
        didSet {
            setViewOnModel()
        }
    }
    private var setViewOnModel = { }

    init<FR: FlowRepresentable & View>(type: FR.Type, args: AnyWorkflow.PassedArgs) {
        super.init(type, args: args)
        guard let instance = underlyingInstance as? FR else {
            fatalError("Could not cast \(String(describing: underlyingInstance)) to expected type: \(FR.self)")
        }
        setViewOnModel = { [weak self] in
            self?.model?.body = AnyView(instance)
        }
    }
}
