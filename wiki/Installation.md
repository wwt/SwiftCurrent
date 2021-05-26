# ORIGINAL
### Swift Package Manager
To use Workflow in a SwiftPM project, add the following line to the dependencies in your Package.swift file:

```swift 
.package(url: "https://github.com/wwt/Workflow")
```

### CocoaPods
Add the following line(s) to your podfile:

#### If you want to use Workflow with UIKit:
```ruby
pod 'DynamicWorkflow/UIKit'
```

#### If you want to use Workflow as a generic construct, and build your own Orchestration Responder:
```ruby
pod 'DynamicWorkflow/Core'
```

# NEW

// reference

Docs for SwiftPM 
- https://swift.org/package-manager/
- https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app

Docs for Cocoapods
- https://cocoapods.org/

Example installation
- https://github.com/Alamofire/Alamofire#installation

-----

## Swift Package Manager
[ need to vet the instructions ]

Docs for SwiftPM 
- https://swift.org/package-manager/
- https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app

### Add the library to a SwiftPM project
Add the following line to the dependencies in your Package.swift file:
```swift 
.package(url: "https://github.com/wwt/Workflow")
```

### Add the library using Xcode
Follow these [instructions](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app).  The URL for the library is:
```
https://github.com/wwt/Workflow
```
Select the `Workflow` package.

Additionally select `WorkflowUIKit` for UIKit support.

## CocoaPods
(Option 1) If you want help installing or getting started with [Cocoapods](https://cocoapods.org/), their website has great documentation for that.

(Option 2) [Cocoapods](https://cocoapods.org/) has great documentation on installation and getting started.

(Option 3) If you want help installing or getting started, the great documentation on [Cocoapods](https://cocoapods.org/) is your best resource.

(Option 4) For help getting started and installing [Cocoapods](https://cocoapods.org/), see their website.

(Option 5) For help getting started and installing [Cocoapods](https://cocoapods.org/), see their great documentation.

// I keep mentioning "great documentation" because I don't want it to read as if we are pawning off the work, but instead that this is the best resource to use.  Essentially, "We can't say it better so look at this".

----

To add Workflow to your dependencies, add the following line(s) to your `Podfile`:

### If you want to use Workflow with UIKit:
```ruby
pod 'DynamicWorkflow/UIKit'
```

### If you want to use Workflow as a generic construct, and build your own [Orchestration Responder](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/OrchestrationResponder.html):
```ruby
pod 'DynamicWorkflow/Core'
```