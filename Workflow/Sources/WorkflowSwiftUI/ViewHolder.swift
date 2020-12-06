//
//  File.swift
//  
//
//  Created by Tyler Thompson on 12/5/20.
//

import Foundation
import SwiftUI
import Workflow

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public class ViewHolder: ObservableObject {
    let view: AnyView
    let metadata: FlowRepresentableMetaData

    var copy: ViewHolder {
        ViewHolder(view: view, metadata: metadata)
    }

    init(view: AnyView, metadata: FlowRepresentableMetaData) {
        self.view = view
        self.metadata = metadata
    }
}
