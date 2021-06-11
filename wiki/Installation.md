# Swift Package Manager

If you want more information about installing Swift packages with Xcode, [follow these instructions](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app). If you want to learn more about Swift Package Manager, [this page goes into detail](https://swift.org/package-manager/).

To use Swift Package Manager in Xcode, click `File` -> `Swift Packages` -> `Add Package Dependency` and enter the Workflow repo's URL.

If you're a framework author and want to use Workflow as a dependency, update your `Package.swift` file:

## Get the package

Add the following line to the package dependencies in `Package.swift`:

```swift
.package(url: "https://github.com/wwt/Workflow.git", .upToNextMajor(from: "3.0.0")),
```

## Get the correct product

Add one one of the following products to your target dependencies.

#### __If you want to use Workflow with UIKit__

```swift
.product(name: "Workflow", package: "Workflow"),
.product(name: "WorkflowUIKit", package: "Workflow")
```

#### __You'll import Workflow for UIKit as such__

```swift
import WorkflowUIKit
```

`WorkflowUIKit` will need to be built on a platform that supports UIKit, such as iOS or macOS with Catalyst.

#### __If you want to use Workflow without UIKit__

```swift
.product(name: "Workflow", package: "Workflow"),
```

#### __You'll import Workflow without UIKit as such__

```swift
import Workflow
```

You will need to build your own [Orchestration Responders](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/OrchestrationResponder.html) for your domains.

# CocoaPods

Set up [CocoaPods](https://cocoapods.org/) for your project, then include Workflow in your dependencies by adding one of the following lines to your `Podfile`:

#### __If you want to use Workflow with UIKit__

```ruby
pod 'DynamicWorkflow/UIKit'
```

#### __If you want to use Workflow without UIKit__

```ruby
pod 'DynamicWorkflow/Core'
```

#### __In both of these cases you'll import Workflow as such__

```swift
import Workflow
```

You will need to build your own [Orchestration Responders](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/OrchestrationResponder.html) for your domains.
