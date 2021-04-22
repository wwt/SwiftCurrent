//
//  ContentView.swift
//  WorkflowSwiftUIExample
//
//  Created by Tyler Thompson on 11/29/20.
//

import SwiftUI
import Workflow
import WorkflowSwiftUI

#warning("Just modal launch style and everything else default does something funky, especially when going backward")
struct ContentView: View {
    var body: some View {
//        T1()
//        Text("Above")
        WorkflowView(Workflow(FR1.self, presentationType: .navigationStack)
                        .thenPresent(FR2.self, presentationType: .navigationStack)
                        .thenPresent(FR3.self, presentationType: .navigationStack)
                        .thenPresent(FR4.self, presentationType: .navigationStack))
//        Text("Below")
    }
}

struct T1: View {
    @State var showing: Bool = false

    var body: some View {
        NavigationView {
            NavigationLink(
                destination: T2(),
                isActive: .init(get: {
                    showing
                }, set: { val in
                    print("NAV SET TO: \(val) ON \(Self.self)")
                    showing = val
                }),
                label: {
                    Text("Navigate to T2")
                }).onAppear(perform: {
                    print("ONAppear for: \(Self.self)")
                }).onDisappear(perform: {
                    print("ONDisAppear for: \(Self.self)")
                })
        }
    }
}

struct T2: View {
    @State var showing: Bool = false

    var body: some View {
        NavigationLink(
            destination: T3(),
            isActive: .init(get: {
                showing
            }, set: { val in
                print("NAV SET TO: \(val) ON \(Self.self)")
                showing = val
            }),
            label: {
                Text("Navigate to T3")
            }).onAppear(perform: {
                print("ONAppear for: \(Self.self)")
            }).onDisappear(perform: {
                print("ONDisAppear for: \(Self.self)")
            })
    }
}

struct T3: View {
    @State var showing: Bool = false

    var body: some View {
        NavigationLink(
            destination: T4(),
            isActive: .init(get: {
                showing
            }, set: { val in
                print("NAV SET TO: \(val) ON \(Self.self)")
                showing = val
            }),
            label: {
                Text("Navigate to T4")
            }).onAppear(perform: {
                print("ONAppear for: \(Self.self)")
            }).onDisappear(perform: {
                print("ONDisAppear for: \(Self.self)")
            })
    }
}

struct T4: View {
    @State var showing: Bool = false

    var body: some View {
        NavigationLink(
            destination: T5(),
            isActive: .init(get: {
                showing
            }, set: { val in
                print("NAV SET TO: \(val) ON \(Self.self)")
                showing = val
            }),
            label: {
                Text("Navigate to T5")
            }).onAppear(perform: {
                print("ONAppear for: \(Self.self)")
            }).onDisappear(perform: {
                print("ONDisAppear for: \(Self.self)")
            })
    }
}

struct T5: View {
    @State var showing: Bool = false

    var body: some View {
        Text("fin")
    }
}

struct FR1: View, FlowRepresentable {
    var _workflowPointer: AnyFlowRepresentable?

    static func instance() -> Self { Self() }

    var body: some View {
        VStack {
            Text("\(String(describing: Self.self))")
                .padding()
            Button("Proceed", action: proceedInWorkflow)
        }
    }
}

struct FR2: View, FlowRepresentable {
    var _workflowPointer: AnyFlowRepresentable?

    static func instance() -> Self { Self() }

    var body: some View {
        VStack {
            Text("\(String(describing: Self.self))")
                .padding()
            Button("Proceed", action: proceedInWorkflow)
            Button("Back", action: proceedBackwardInWorkflow)
        }
    }
}

struct FR3: View, FlowRepresentable {
    var _workflowPointer: AnyFlowRepresentable?

    static func instance() -> Self { Self() }

    var body: some View {
        VStack {
            Text("\(String(describing: Self.self))")
                .padding()
            Button("Proceed", action: proceedInWorkflow)
            Button("Back", action: proceedBackwardInWorkflow)
        }
    }
}

struct FR4: View, FlowRepresentable {
    var _workflowPointer: AnyFlowRepresentable?

    static func instance() -> Self { Self() }

    var body: some View {
        VStack {
            Text("\(String(describing: Self.self))")
                .padding()
            Button("Back", action: proceedBackwardInWorkflow)
            Button("Abandon") {
                workflow?.abandon()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
