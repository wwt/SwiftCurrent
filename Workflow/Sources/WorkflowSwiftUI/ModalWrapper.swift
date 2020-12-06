//
//  ModalWrapper.swift
//  
//
//  Created by Tyler Thompson on 12/5/20.
//

import Foundation
import SwiftUI
import Workflow

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
struct ModalWrapper: View {
    @EnvironmentObject var model: WorkflowModel
    @EnvironmentObject var holder: ViewHolder

    let next: AnyView
    let current: AnyView
    let style: LaunchStyle.PresentationType.ModalPresentationStyle

    var body: some View {
        #warning("Is there a way to test the binding boolean getter value here?")
        switch style {
            case .default:
                current.sheet(isPresented: .init(get: {
                    model.stack.contains(where: { $0.value === holder })
                }, set: { val in
                    if !val {
                        model.stack.removeLast()
                    }
                }), content: {
                    next
                })
            case .fullScreen: if #available(iOS 14.0, *) {
                current.fullScreenCover(isPresented: .init(get: {
                    model.stack.contains(where: { $0.value === holder })
                }, set: { val in
                    if !val {
                        model.stack.removeLast()
                    }
                }), content: {
                    next
                })
            }
        }
    }
}
