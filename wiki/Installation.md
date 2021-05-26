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

### Add the library to a SwiftPM project *
Add the following line to the dependencies in your Package.swift file:
```swift 
.package(url: "https://github.com/wwt/Workflow")
```

### Add the library using Xcode
Follow these [instructions](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app).  The URL for the library is:
```
https://github.com/wwt/Workflow
```
Select the `WorkflowUIKit` for UIKit support.

Select the `Workflow` package.

## CocoaPods
Set up [CocoaPods](https://cocoapods.org/) for your project, then include Workflow in your dependencies by adding one of the following lines to your `Podfile`: 

### If you want to use Workflow with UIKit:
```ruby
pod 'DynamicWorkflow/UIKit'
```

### If you only want the core tools to create [Workflows]():
```ruby
pod 'DynamicWorkflow/Core'
```
You will need to build your own [Orchestration Responders](https://gitcdn.link/cdn/wwt/Workflow/faf9273f154954848bf6b6d5c592a7f0740ef53a/docs/Protocols/OrchestrationResponder.html) for your domains.
