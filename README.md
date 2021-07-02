<!-- Library Information -->
[![Supported Platforms](https://img.shields.io/cocoapods/p/SwiftCurrent)](https://github.com/wwt/SwiftCurrent/security/policy)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-supported-brightgreen)](https://github.com/wwt/SwiftCurrent/wiki/Installation#swift-package-manager)
[![Pod Version](https://img.shields.io/cocoapods/v/SwiftCurrent.svg?style=popout)](https://github.com/wwt/SwiftCurrent/wiki/Installation#cocoapods)
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

Clone our repo, open `SwiftCurrent.xcworkspace`, target the `SwiftCurrentExample` scheme, and run to see our example app in action.

The app is designed to give you an idea of what SwiftCurrent can do with minimal overhead in the UI.  The key areas of code you'll want to look at are: `SetupViewController.swift` and the view controllers referenced in the [Workflow](https://wwt.github.io/SwiftCurrent/Classes/Workflow.html).

## Interested but you need SwiftUI support?

[We're working on it now!](https://github.com/wwt/SwiftCurrent/milestone/2)

# Quick Start

This quick start uses SPM, but for other approaches, [see our installation instructions](https://github.com/wwt/SwiftCurrent/wiki/Installation).

## UIKit

```swift
.package(url: "https://github.com/wwt/SwiftCurrent.git", .upToNextMajor(from: "4.0.0")),
...
.product(name: "SwiftCurrent", package: "SwiftCurrent"),
.product(name: "SwiftCurrent_UIKit", package: "SwiftCurrent")
```
Then make your first FlowRepresentable view controller:
```swift
import SwiftCurrent
import SwiftCurrent_UIKit
class ExampleViewController: UIWorkflowItem<Never, Never>, FlowRepresentable {
    override func viewDidLoad() {
        view.backgroundColor = .green
    }
}
```
Then from your root view controller, call: 
```swift
import SwiftCurrent
...
launchInto(Workflow(ExampleViewController.self))
```

And just like that you're started!

# Deep Dive

- [Why SwiftCurrent?](https://github.com/wwt/SwiftCurrent/wiki/Why-This-Library%3F)
- [Installation](https://github.com/wwt/SwiftCurrent/wiki/Installation)
- [Getting Started with Storyboards](https://github.com/wwt/SwiftCurrent/wiki/getting-started)
- [Getting Started with Programmatic UIKit](https://github.com/wwt/SwiftCurrent/wiki/Getting-Started-with-Programmatic-UIKit)
- [Developer Documentation](https://wwt.github.io/SwiftCurrent/index.html)
- [Upgrade Path](https://github.com/wwt/SwiftCurrent/blob/main/wiki/UPGRADE_PATH.md)

# Feedback

If you like what you've seen, consider [giving us a star](https://github.com/wwt/SwiftCurrent/stargazers)! If you don't, let us know [how we can improve](https://github.com/wwt/SwiftCurrent/discussions/new).

<!-- Social Media -->
[![Stars](https://img.shields.io/github/stars/wwt/SwiftCurrent?style=social)](https://github.com/wwt/SwiftCurrent/stargazers)
[![Twitter](https://img.shields.io/twitter/url?style=social&url=https%3A%2F%2Ftwitter.com%2FSwiftCurrentWWT)](https://twitter.com/SwiftCurrentWWT)
 
