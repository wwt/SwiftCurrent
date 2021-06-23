//
//  SwiftCurrentExample_SwiftUIApp.swift
//  SwiftCurrentExample_SwiftUI
//
//  Created by Richard Gist on 6/21/21.
//

import SwiftUI

@main
struct SwiftCurrentExample_SwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
//            ContentView()
//            SampleView()
            Tester()
        }
    }
}

struct Tester: View {
    @State var show = false

    var body: some View {
        if show {
            Text("Foo")
                .transition(.slide)
        }
        Button(show ? "Hide" : "Show") { withAnimation { show.toggle() } }

        LazyVStack(alignment: .center, spacing: nil, pinnedViews: [], content: {
            ForEach(1...10, id: \.self) { count in
                Text("Placeholder \(count)")
            }
        })
    }
}
