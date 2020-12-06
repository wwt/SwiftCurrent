//
//  NavWrapper.swift
//  
//
//  Created by Tyler Thompson on 12/5/20.
//

import Foundation
import SwiftUI

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
struct NavWrapper: View {
    @EnvironmentObject var model: WorkflowModel
    @EnvironmentObject var holder: ViewHolder

    let next: AnyView
    let current: AnyView

    var body: some View {
        VStack {
            current
            NavigationLink(
                destination: next,
                isActive: .init(get: {
                    model.stack.contains(where: { $0.value === holder })
                }, set: { val in
                    if !val {
                        model.stack.removeLast()
                    }
                }),
                label: {
                    EmptyView()
                })
        }
    }
}
