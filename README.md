![SwiftCurrent](https://user-images.githubusercontent.com/79471462/131564417-6f4976f4-270c-41b3-bbe1-428528e2cc2c.png)

<!-- Library Information -->
[![Supported Platforms](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-lightgrey)](https://github.com/wwt/SwiftCurrent/security/policy)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-supported-brightgreen)](https://wwt.github.io/SwiftCurrent/installation.html#swift-package-manager)
[![Pod Version](https://img.shields.io/cocoapods/v/SwiftCurrent.svg?style=popout)](https://wwt.github.io/SwiftCurrent/installation.html#cocoapods)
[![License](https://img.shields.io/github/license/wwt/SwiftCurrent)](https://github.com/wwt/SwiftCurrent/blob/main/LICENSE)
[![Build Status](https://github.com/wwt/SwiftCurrent/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/wwt/SwiftCurrent/actions?query=branch%3Amain)
[![Code Coverage](https://codecov.io/gh/wwt/SwiftCurrent/branch/main/graph/badge.svg?token=04Q5KSHict)](https://codecov.io/gh/wwt/SwiftCurrent)

# Welcome

SwiftCurrent is a library that lets you easily manage journeys through your Swift application and comes with built-in support for UIKit and SwiftUI app-routing.

## Why Should I Use SwiftCurrent?

In SwiftCurrent, workflows are a sequence of operations. Those operations usually display views in an application. The workflow describes the sequence of views and manages which view should come next. Your views are responsible for performing necessary tasks before proceeding forward in the workflow, like processing user input.

Architectural patterns and libraries that attempt to create a separation between views and workflows already exist. However, SwiftCurrent is different. We took a new design approach that focuses on:

- **A Developer-Friendly API**. The library was built with developers in mind. It started with a group of developers talking about the code experience they desired. Then the library team took on whatever complexities were necessary to bring them that experience.
- **Compile-Time Safety**. At compile-time, we tell you everything we can so you know things will work.
- **Minimal Boilerplate**. We have hidden this as much as possible. We hate it as much as you do and are constantly working on cutting the cruft.

### From There, We Created a Library

This library:

- **Isolates Your Views**. Design your views so that they are unaware of the view that will come next.
- **Easily Reorders Views**. Changing view order is as easy as ⌘+⌥+\[ (moving the line up or down).
- **Composes Workflows Together**. Create branching flows easily by joining workflows together.
- **Creates Conditional Flows**. Make your flows robust and handle ever-changing designs. Need a screen to only to show up sometimes? Need a flow for person A and another for person B? We've got you covered.

# Quick Start

Why show a quick start when we have an example app? Because it's so easy to get started, we can drop in two code snippets, and you're ready to go! This quick start uses Swift Package Manager and SwiftUI, but for other approaches, [see our installation instructions](https://wwt.github.io/SwiftCurrent/installation.html).

```swift
.package(url: "https://github.com/wwt/SwiftCurrent.git", .upToNextMajor(from: "5.1.0")),
...
.product(name: "SwiftCurrent", package: "SwiftCurrent"),
.product(name: "SwiftCurrent_SwiftUI", package: "SwiftCurrent")
```

Then make your first FlowRepresentable view:

```swift
import SwiftCurrent
import SwiftUI
struct OptionalView: View, FlowRepresentable {
    weak var _workflowPointer: AnyFlowRepresentable?
    let input: String
    init(with args: String) { input = args }
    var body: some View { Text("Only shows up if no input") }
    func shouldLoad() -> Bool { input.isEmpty }
}
struct ExampleView: View, PassthroughFlowRepresentable {
    weak var _workflowPointer: AnyFlowRepresentable?
    var body: some View { Text("This is ExampleView!") }
}
```

Then from your `ContentView` or whatever view (or app) you'd like to contain the workflow, add the following view to the body:

```swift
import SwiftCurrent_SwiftUI
// ...
var body: some View { 
    // ... other view code (if any)
    WorkflowView(launchingWith: "Skip optional screen") {
        WorkflowItem(OptionalView.self)
        WorkflowItem(ExampleView.self)
    }
}
```

And just like that, you've got a workflow! You can now add more items to it or reorder the items that are there. To understand more of how this works, [check out our developer docs.](https://wwt.github.io/SwiftCurrent/How%20to%20use%20SwiftCurrent%20with%20SwiftUI.html)

# Server Driven Workflows
SwiftCurrent now supports server driven workflows! Check out our schema for details on defining workflows with JSON, YAML, or any other key/value-based data format. Then, simply have your `FlowRepresentable` types that you wish to decode conform to `WorkflowDecodable` and decode the workflow. For more information, [see our docs](https://wwt.github.io/SwiftCurrent/Server%20Driven%20Workflows.html).

# Look at Our Example Apps

We have [example apps](https://github.com/wwt/SwiftCurrent/tree/main/ExampleApps) for both SwiftUI and UIKit that show SwiftCurrent in action. They've already been tested, so you can see what it's like to test SwiftCurrent code. To run it locally, start by cloning the repo, open `SwiftCurrent.xcworkspace` and then run the `SwiftUIExample` scheme or the `UIKitExample` scheme.

# [Click Here to Learn More](https://wwt.github.io/SwiftCurrent/Creating%20Workflows.html)

For specific documentation check out:

- [Why SwiftCurrent?](https://wwt.github.io/SwiftCurrent/why-this-library.html)
- [Installation](https://wwt.github.io/SwiftCurrent/installation.html)
- [Getting Started With SwiftUI](https://wwt.github.io/SwiftCurrent/getting-started-with-swiftui.html)
- [Getting Started With Storyboards](https://wwt.github.io/SwiftCurrent/using-storyboards.html)
- [Getting Started With Programmatic UIKit Views](https://wwt.github.io/SwiftCurrent/using-programmatic-views.html)
- [Server Driven Workflows](https://wwt.github.io/SwiftCurrent/Server%20Driven%20Workflows.html)
- [Developer Documentation](https://wwt.github.io/SwiftCurrent/index.html)
- [Upgrade Path](https://github.com/wwt/SwiftCurrent/blob/main/.github/UPGRADE_PATH.md)
- [Contributing to SwiftCurrent](https://github.com/wwt/SwiftCurrent/blob/main/.github/CONTRIBUTING.md)

# Feedback

If you like what you've seen, consider [giving us a star](https://github.com/wwt/SwiftCurrent/stargazers)! If you don't, let us know [how we can improve](https://github.com/wwt/SwiftCurrent/discussions/new).

<!-- Social Media -->
[![Stars](https://img.shields.io/github/stars/wwt/SwiftCurrent?style=social)](https://github.com/wwt/SwiftCurrent/stargazers)

# Special Thanks

SwiftCurrent would not be nearly as amazing without all of the great work done by the authors of our test dependencies:

- [CwlCatchException](https://github.com/mattgallagher/CwlCatchException)
- [CwlPreconditionTesting](https://github.com/mattgallagher/CwlPreconditionTesting)
- [ExceptionCatcher](https://github.com/sindresorhus/ExceptionCatcher)
- [UIUTest](https://github.com/nallick/UIUTest)
- [ViewInspector](https://github.com/nalexn/ViewInspector)
