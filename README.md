![Build Status](https://github.com/wwt/Workflow/actions/workflows/CI.yml/badge.svg?branch=main)
![Pod Version](https://img.shields.io/cocoapods/v/DynamicWorkflow.svg?style=popout)
![Quality Gate](https://img.shields.io/sonar/quality_gate/wwt_Workflow?server=https%3A%2F%2Fsonarcloud.io)
![Coverage](https://img.shields.io/sonar/coverage/wwt_Workflow?server=http%3A%2F%2Fsonarcloud.io)

# Welcome
Workflow is a library that lets you easily manage journeys through your Swift application.

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

As you continue to develop your applications, each view controller will become more decoupled from the rest of the app.  That means, if you want a completely different order of screens, just define a new [Workflow](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Classes/Workflow.html).

## Interested but you need SwiftUI support?
[We're working on it now!](https://github.com/wwt/Workflow/milestone/2)

# Quick Start
## CocoaPods
```ruby
pod 'DynamicWorkflow/UIKit'
```
Then make your first FlowRepresentable view controller:
```swift
import Workflow
class ExampleViewController: UIWorkflowItem<Never, Never>, FlowRepresentable {
    override func viewDidLoad() {
        view.backgroundColor = .green
    }
}
```
Then from your root view controller, call: 
```swift
import Workflow
...
launchInto(Workflow(ExampleViewController.self))
```

And just like that you're started!  To see something more practical and in-depth, check out the example app in the repo.  For a more in-depth starting guide, checkout out our [Getting Started](https://github.com/wwt/Workflow/wiki/getting-started) documentation.

# Deep Dive
- [Why Workflow?](https://github.com/wwt/Workflow/wiki/Why-This-Library%3F)
- [Installation](https://github.com/wwt/Workflow/wiki/Installation)
- [Getting Started with Storyboards](https://github.com/wwt/Workflow/wiki/getting-started)
- [Getting Started with Programmatic UIKit](https://github.com/wwt/Workflow/wiki/Getting-Started-with-Programmatic-UIKit)
- [Developer Documentation](https://gitcdn.link/repo/wwt/Workflow/main/docs/index.html)
- [Upgrade Path](https://github.com/wwt/Workflow/blob/main/UPGRADE_PATH.md)
