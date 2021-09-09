![SwiftCurrent](https://user-images.githubusercontent.com/79471462/131564417-6f4976f4-270c-41b3-bbe1-428528e2cc2c.png)

<!-- Library Information -->
[![Supported Platforms](https://img.shields.io/cocoapods/p/SwiftCurrent)](https://github.com/wwt/SwiftCurrent/security/policy)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-supported-brightgreen)](https://wwt.github.io/SwiftCurrent/installation.html#swift-package-manager)
[![Pod Version](https://img.shields.io/cocoapods/v/SwiftCurrent.svg?style=popout)](https://wwt.github.io/SwiftCurrent/installation.html#cocoapods)
[![License](https://img.shields.io/github/license/wwt/SwiftCurrent)](https://github.com/wwt/SwiftCurrent/blob/main/LICENSE)
[![Build Status](https://github.com/wwt/SwiftCurrent/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/wwt/SwiftCurrent/actions?query=branch%3Amain)
[![Code Coverage](https://codecov.io/gh/wwt/SwiftCurrent/branch/main/graph/badge.svg?token=04Q5KSHict)](https://codecov.io/gh/wwt/SwiftCurrent)


# Welcome

SwiftCurrent is a library that lets you easily manage journeys through your Swift application.

It comes with built-in support for UIKit and SwiftUI app-routing. In SwiftCurrent workflows are a sequence of operations. Those operations are normally showing views in an application. The workflow describes the sequence of views and manages what view should come next. Your views are responsible for performing necessary tasks before proceeding forward in the workflow, like processing user input.

https://user-images.githubusercontent.com/33705774/132767762-7447753c-feba-4ef4-b54c-38bfe9d1ee82.mp4

### Why should I use SwiftCurrent?
Architectural patterns and libraries that attempt to create a separation between views and workflows already exist. However, SwiftCurrent is different. We took a new design approach that focuses on

- **A Developer Friendly API**: The library was built with developers in mind. It started with a group of developers talking about the code experience they desired. Then the library team took on whatever complexities were necessary to bring them that experience.
- **Compile-time safety**: We tell you at compile time everything we can so you know things will work.
- **Minimal Boilerplate**: We have hidden this as much as possible. We hate it as much as you do and are constantly working on cutting the cruft.

#### From there, we created a library that:
- **Isolates your views**:  You can design your views so that they are unaware of the view that will come next.
- **Easily reorders views**: Changing view order is as easy as ⌘+⌥+\[ (moving the line up or down)
- **Composes workflows together**: Create branching flows easily by joining workflows together.
- **Creates conditional flows**: Make your flows robust and handle ever-changing designs. Need a screen only to show up sometimes? Need a flow for person A and another for person B? We've got you covered.

# Quick Start

This quick start uses SPM, but for other approaches, [see our installation instructions](https://wwt.github.io/SwiftCurrent/installation.html).

## SwiftUI

```swift
.package(url: "https://github.com/wwt/SwiftCurrent.git", .upToNextMajor(from: "4.1.0")),
...
.product(name: "SwiftCurrent", package: "SwiftCurrent"),
.product(name: "BETA_SwiftCurrent_SwiftUI", package: "SwiftCurrent")
```
Then make your first FlowRepresentable view:
```swift
import SwiftCurrent
struct OptionalView: View, FlowRepresentable {
    weak var _workflowPointer: AnyFlowRepresentable?
    let input: String
    init(with args: String) { input = args }
    var body: some View { Text("Only shows up if no input") }
    func shouldLoad() -> Bool { input.isEmpty }
}
struct ExampleView: View, FlowRepresentable {
    weak var _workflowPointer: AnyFlowRepresentable?
    var body: some View { Text("This is ExampleView!") }
}
```
Then from your ContentView body, add: 
```swift
import SwiftCurrent_SwiftUI
...
WorkflowLauncher(isLaunched: .constant(true), startingArgs: "Skip optional screen") {
    thenProceed(with: OptionalView.self) {
        thenProceed(with: ExampleView.self)
    }
}
```

And just like that you're started!

### [Check out our example apps](https://github.com/wwt/SwiftCurrent/tree/main/ExampleApps)
We have example apps for both SwiftUI and UIKit that show SwiftCurrent in action. They're even tested so you can see what it's like to test SwiftCurrent code. To run it locally, start by cloning the repo, open `SwiftCurrent.xcworkspace` and then run the `SwiftUIExample` scheme or the `UIKitExample` scheme. 

# Deep Dive

- [Why SwiftCurrent?](https://wwt.github.io/SwiftCurrent/why-this-library.html)
- [Installation](https://wwt.github.io/SwiftCurrent/installation.html)
- [Getting Started with Storyboards](https://wwt.github.io/SwiftCurrent/using-storyboards.html)
- [Getting Started with Programmatic UIKit Views](https://wwt.github.io/SwiftCurrent/using-programmatic-views.html)
- [[BETA] Getting Started with SwiftUI](https://wwt.github.io/SwiftCurrent/getting-started-with-swiftui.html)
- [Developer Documentation](https://wwt.github.io/SwiftCurrent/index.html)
- [Upgrade Path](https://github.com/wwt/SwiftCurrent/blob/main/.github/UPGRADE_PATH.md)
- [Contributing to SwiftCurrent](https://github.com/wwt/SwiftCurrent/blob/main/.github/CONTRIBUTING.md)

# Feedback

If you like what you've seen, consider [giving us a star](https://github.com/wwt/SwiftCurrent/stargazers)! If you don't, let us know [how we can improve](https://github.com/wwt/SwiftCurrent/discussions/new).

<!-- Social Media -->
[![Stars](https://img.shields.io/github/stars/wwt/SwiftCurrent?style=social)](https://github.com/wwt/SwiftCurrent/stargazers)
[![Twitter](https://img.shields.io/twitter/url?style=social&url=https%3A%2F%2Ftwitter.com%2FSwiftCurrentWWT)](https://twitter.com/SwiftCurrentWWT)

# Special Thanks

SwiftCurrent would not be nearly as amazing without all of the great work done by the authors of our test dependencies:

- [CwlCatchException](https://github.com/mattgallagher/CwlCatchException)
- [CwlPreconditionTesting](https://github.com/mattgallagher/CwlPreconditionTesting)
- [ExceptionCatcher](https://github.com/sindresorhus/ExceptionCatcher)
- [UIUTest](https://github.com/nallick/UIUTest)
- [ViewInspector](https://github.com/nalexn/ViewInspector)
