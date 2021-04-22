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

    @State var appearCount = 0

    var isShowing: Bool {
        appearCount > 0
    }

    var body: some View {
        VStack {
            current
            NavigationLink(
                destination: next,
                isActive: .init(get: {
                    model.stack.contains(where: { $0.value === holder })
                }, set: { val in
                    if isShowing && !val {
                        if let currentNode = model.stack.first(where: { $0.value === holder }) {
                            model.stack.remove { $0 === currentNode.next }
                            currentNode.value = holder.copy
                        }
                    }
                }),
                label: {
                    EmptyView()
                }).onAppear { appearCount = 1 }
                .onDisappear { appearCount -= 1 }
        }
    }
}
