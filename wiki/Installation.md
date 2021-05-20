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