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

When Developing in UIKit, each view controller has to know about the one following it in order to share data.  Now imagine a flow where the first 3 screens are optional.  What would it look like if you could decouple all of that?

```swift
let workflow = Workflow(LocationsViewController.self) // Skip this if you have GPS
                .thenProceed(with: PickupOrDeliveryViewController.self) // Skip this if you only have 1 choice
                .thenProceed(with: MenuSelectionViewController.self) // Skip this for new stores
                .thenProceed(with: FoodSelectionViewController.self)
                .thenProceed(with: ReviewOrderViewController.self) // This lets you edit anything you've already picked
                .thenProceed(with: SubmitPaymentViewController.self)

// from wherever this flow is launched
launchInto(workflow)
```
The above code is all that is needed from the screen starting this flow. Each screen determines if it needs to show based on data passed in and what that screen knows about the system (such as GPS availability), and all of it is type safe. If you ever want to re-order these, simply move their position in the chain.

As you continue to develop your applications, each view controller will become more decoupled from the rest of the app.  That means, if you want a completely different order of screens, just define a new [Workflow](https://wwt.github.io/SwiftCurrent/Classes/Workflow.html).

## See it in action with our example app

Clone our repo, open `SwiftCurrent.xcworkspace`, target the `UIKitExample` scheme, and run to see our example app in action.

The [example app has a README](https://github.com/wwt/SwiftCurrent/blob/main/ExampleApps/UIKitExample/README.md) that details interesting usages.

## Interested but you need SwiftUI support?

[We're working on it now!](https://github.com/wwt/SwiftCurrent/milestone/2)

If you would like to try the beta release, please install the `BETA_SwiftCurrent_SwiftUI` product in SPM or the `BETA_SwiftUI` sub spec in CocoaPods.  For more detailed steps, [see our installation instructions](https://wwt.github.io/SwiftCurrent/installation.html).  See [Getting Started with SwiftUI](https://wwt.github.io/SwiftCurrent/getting-started-with-swiftui.html) for a quick tutorial.  To see the example app for SwiftUI, clone our repo, open `SwiftCurrent.xcworkspace`, target the `SwiftUIExample` scheme, and run. The [example app has a README](https://github.com/wwt/SwiftCurrent/blob/main/ExampleApps/SwiftUIExample/README.md) that details interesting usages.

In order to use the library with SwiftUI, your minimum targeted versions must meet: iOS 14.0, macOS 11, tvOS 14.0, or watchOS 7.0.

For us, beta means that the API may change without warning until the full release.  However, we expect bugs to be at a minimum and documentation to be true and accurate.

# Quick Start

This quick start uses SPM, but for other approaches, [see our installation instructions](https://wwt.github.io/SwiftCurrent/installation.html).

## UIKit

```swift
.package(url: "https://github.com/wwt/SwiftCurrent.git", .upToNextMajor(from: "4.0.0")),
...
.product(name: "SwiftCurrent", package: "SwiftCurrent"),
.product(name: "SwiftCurrent_UIKit", package: "SwiftCurrent")
```
Then make your first FlowRepresentable view controllers:
```swift
import SwiftCurrent
import SwiftCurrent_UIKit
class OptionalViewController: UIWorkflowItem<String, Never>, FlowRepresentable {
    let input: String
    required init(with args: String) {
        input = args
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { nil }
    override func viewDidLoad() { view.backgroundColor = .blue }
    func shouldLoad() -> Bool { input.isEmpty }
}
class ExampleViewController: UIWorkflowItem<Never, Never>, FlowRepresentable {
    override func viewDidLoad() { view.backgroundColor = .green }
}
```
Then from your root view controller, call:
```swift
import SwiftCurrent
...
let workflow = Workflow(OptionalViewController.self)
    .thenProceed(with: ExampleViewController.self)
launchInto(workflow, args: "Skip optional screen")
```

And just like that you're started!

## [BETA] SwiftUI

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

Here's an example of an app written with SwiftCurrent running wherever SwiftUI runs.  Check it out:

https://user-images.githubusercontent.com/79471462/131555558-9e01e753-cafd-4ae2-af1b-b71a1aabb71f.mp4


# Deep Dive

- [Why SwiftCurrent?](https://wwt.github.io/SwiftCurrent/why-this-library.html)
- [Installation](https://wwt.github.io/SwiftCurrent/installation.html)
- [Getting Started with Storyboards](https://wwt.github.io/SwiftCurrent/getting-started-with-storyboards.html)
- [Getting Started with Programmatic UIKit Views](https://wwt.github.io/SwiftCurrent/getting-started-with-programmatic-views.html)
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
