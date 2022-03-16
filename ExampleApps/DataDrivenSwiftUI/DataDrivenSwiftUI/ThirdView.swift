//
//  ThirdView.swift
//  SwiftCurrent
//
//  Created by Nick Kaczmarek on 3/16/22.
//  Copyright © 2022 WWT and Tyler Thompson. All rights reserved.
//  

import SwiftUI
import SwiftCurrent

struct ThirdView: View, FlowRepresentable, WorkflowDecodable {
    var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        VStack {
            Text("Hello from the server!")
            Button("Go somewhere") {
                proceedInWorkflow()
            }
        }

    }
}

struct ThirdView_Previews: PreviewProvider {
    static var previews: some View {
        ThirdView()
    }
}
