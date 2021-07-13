//
//  WorkflowViewModel.swift
//  SwiftCurrent_SwiftUI
//
//  Created by Megan Wiemer on 7/13/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import SwiftCurrent
import SwiftUI

final class WorkflowViewModel: ObservableObject {
    @Published var body = AnyView(EmptyView())
}

extension WorkflowViewModel: OrchestrationResponder {
    func launch(to: AnyWorkflow.Element) {
        #warning("come back to this")
        // swiftlint:disable:next force_cast
        let afrv = to.value.instance as! AnyFlowRepresentableView

        afrv.model = self
    }

    func proceed(to: AnyWorkflow.Element, from: AnyWorkflow.Element) {
        #warning("come back to this")
        // swiftlint:disable:next force_cast
        let afrv = to.value.instance as! AnyFlowRepresentableView

        afrv.model = self
    }

    func backUp(from: AnyWorkflow.Element, to: AnyWorkflow.Element) {
        #warning("come back to this")
        // swiftlint:disable:next force_cast
        let afrv = to.value.instance as! AnyFlowRepresentableView

        afrv.model = self
    }

    func abandon(_ workflow: AnyWorkflow, onFinish: (() -> Void)?) {

    }

    func complete(_ workflow: AnyWorkflow, passedArgs: AnyWorkflow.PassedArgs, onFinish: ((AnyWorkflow.PassedArgs) -> Void)?) {
        onFinish?(passedArgs)
    }
}
