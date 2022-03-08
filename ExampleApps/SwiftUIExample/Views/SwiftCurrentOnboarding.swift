//
//  SwiftCurrentOnboarding.swift
//  SwiftUIExample
//
//  Created by Tyler Thompson on 8/26/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  swiftlint:disable line_length closure_body_length

import SwiftUI
import SwiftCurrent

struct SwiftCurrentOnboarding: View, PassthroughFlowRepresentable {
    @AppStorage("OnboardedToSwiftCurrent", store: .fromDI) private var onboardedToSwiftCurrent = false

    let inspection = Inspection<Self>() // ViewInspector
    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        VStack {
            Image.socialMediaIcon
                .resizable()
                .scaledToFit()
                .padding(.horizontal)
            ScrollView {
                LazyVStack(spacing: 50, pinnedViews: [.sectionHeaders]) {
                    Section(header: SectionHeader(title: "Design Philosphy")) {
                        BenefitView(image: "person.fill.checkmark",
                                    title: "A Developer Friendly API",
                                    description: "The library was built with developers in mind. It started with a group of developers talking about the code experience they desired. Then the library team took on whatever complexities were necessary to bring them that experience.")
                        BenefitView(image: "play.fill",
                                    title: "Compile-time safety",
                                    description: "We tell you at compile time everything we can so you know things will work.")
                        BenefitView(image: "keyboard",
                                    title: "Minimal Boilerplate",
                                    description: "We have hidden this as much as possible. We hate it as much as you do and are constantly working on cutting the cruft.")
                    }
                    Section(header: SectionHeader(title: "Our Library")) {
                        BenefitView(image: "point.topleft.down.curvedto.point.bottomright.up",
                                    title: "Isolates your views",
                                    description: "You can design your views so that they are unaware of the view that will come next.")
                        BenefitView(image: "arrow.up.arrow.down",
                                    title: "Easily reorders views",
                                    description: "Changing view order is as easy as ⌘+⌥+[ (moving the line up or down)")
                        BenefitView(image: "arrow.triangle.branch",
                                    title: "Composes workflows together",
                                    description: "Create branching flows easily by joining workflows together.")
                        BenefitView(image: "switch.2",
                                    title: "Creates conditional flows",
                                    description: "Make your flows robust and handle ever-changing designs. Need a screen only to show up sometimes? Need a flow for person A and another for person B? We've got you covered.")
                    }

                    Section(header: SectionHeader(title: "Where can I use it?")) {
                        BenefitView(image: "arrow.left.arrow.right",
                                    title: "Works with SwiftUI and UIKit",
                                    description: "We've got 1st party support for SwiftUI and UIKit, with an API that feels natural for each. You can even interoperate between SwiftUI and UIKit seamlessly when defining your workflows.")
                        BenefitView(image: "laptopcomputer.and.iphone",
                                    title: "Multiple platform support",
                                    description: "iOS ✅, tvOS ✅, macOS ✅, macOS (Catalyst) ✅, watchOS ✅, iPadOS ✅")
                        BenefitView(image: "swift",
                                    title: "Works with the latest version of Swift",
                                    description: "From Swift 5.0 to 5.5, we got you covered. We're even keeping track of all the pre-releases to keep us feeling natural and operating efficiently.")
                    }
                    Section(header: SectionHeader(title: "What else can it do?")) {
                        Group {
                            BenefitView(image: "arrow.triangle.swap",
                                        title: "Optionally skip screens",
                                        description: "Create onboarding experiences that only show up once, or have screens that appear in a workflow based on other data conditions.")
                            BenefitView(image: "arrow.turn.up.forward.iphone",
                                        title: "Delegate to UIKit or SwiftUI",
                                        description: "When you use SwiftCurrent, you're just using an abstraction. We do not hold onto a view stack; we don't have our own UI system. We simply abstract what you would've written in UIKit or SwiftUI for view navigation.")
                            BenefitView(image: "square.stack.3d.down.right",
                                        title: "Manage your view stacks",
                                        description: "Workflows can contextually set up navigation views and modals for you. Check out our sample app for more details.")
                            BenefitView(image: "arrow.uturn.left.circle",
                                        title: "Reuse views between workflows",
                                        description: "Sometimes, you need to use the same view to collect data but pass it to a different workflow. Using SwiftCurrent, you won't have to change anything about your view code.")
                            BenefitView(image: "iphone.badge.play",
                                        title: "Preview friendly",
                                        description: "SwiftCurrent ties into the SwiftUI ecosystem, so your previews can render your workflows without having to run the app.")
                            BenefitView(image: "gearshape.2",
                                        title: "Efficient",
                                        description: "SwiftCurrent preserves all your type information, so when using SwiftUI, you still get the optimizations you expect, no AnyViews here!")
                            BenefitView(image: "move.3d",
                                        title: "Animation Friendly",
                                        description: "The animations you attach to views work just as well with SwiftCurrent, as they do without it.")
                            BenefitView(image: "eye.fill",
                                        title: "See all your workflows in one spot",
                                        description: "We surface the complex paths of your app upfront. Making it easier to reason through.")
                            BenefitView(image: "rectangle.3.offgrid",
                                        title: "Views not screens",
                                        description: "In SwiftUI, workflows can be just a view on your screen. You can even have multiple workflows on the same screen.")
                            BenefitView(image: "circle.grid.cross.left.fill",
                                        title: "You do you",
                                        description: "We value your ability to choose. We checked our assumptions when designing so you could do the most, with the best.")
                        }
                        Group {
                            BenefitView(image: "rectangle.3.offgrid.bubble.left",
                                        title: "Respond to change",
                                        description: "If somebody wants to change the workflow in your application, it's just a matter of deciding what workflow you want. You can A/B test new workflows, you can change based on preconditions, and you can respond to new design requirements, all with minimal tweaks to your code.")
                            BenefitView(image: "flowchart",
                                        title: "More than UI management",
                                        description: "We separated our logic so you can build on top of it. UIKit ✅ SwiftUI ✅ What do you want next? You can make it!")
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding()
            }.listStyle(GroupedListStyle())

            PrimaryButton(title: "Check It Out!") {
                withAnimation {
                    onboardedToSwiftCurrent = true
                    proceedInWorkflow()
                }
            }
        }.onReceive(inspection.notice) { inspection.visit(self, $0) } // ViewInspector
    }

//    func shouldLoad() -> Bool {
//        !onboardedToSwiftCurrent
//    }
}

extension SwiftCurrentOnboarding {
    struct BenefitView: View {
        let image: String
        let title: String
        let description: String

        var body: some View {
            HStack {
                Image(systemName: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color.icon)
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(description)
                }
                Spacer()
            }
        }
    }

    struct SectionHeader: View {
        let title: String

        var body: some View {
            HStack {
                Spacer()
                Text(title).titleStyle()
                Spacer()
            }.background(Color.black.opacity(0.8))
        }
    }
}

struct SwiftCurrentOnboarding_Previews: PreviewProvider {
    static var previews: some View {
        SwiftCurrentOnboarding()
            .preferredColorScheme(.dark)
    }
}
