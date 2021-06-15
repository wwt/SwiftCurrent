# Swift Package Manager

If you want more information about installing Swift packages through Xcode, [follow these instructions](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app). If you want to learn more about Swift Package Manager, [this page goes into detail](https://swift.org/package-manager/).

If you're a framework author and want to use SwiftCurrent as a dependency, update your `Package.swift` file.

## Get the package

Add the following line to the package dependencies

```swift
.package(url: "https://github.com/wwt/SwiftCurrent.git", .upToNextMajor(from: "4.0.0")),
```

## Get the correct product

Add one one of the following products to your target dependencies.

#### **If you want to use SwiftCurrent with UIKit**

```swift
.product(name: "SwiftCurrent", package: "SwiftCurrent"),
.product(name: "SwiftCurrent_UIKit", package: "SwiftCurrent")
```

#### **Your import statement in this case will be**

```swift
import SwiftCurrent_UIKit
```

`WorkflowUIKit` will need to be built for a platform that supports UIKit, such as iOS or macOS with Catalyst.

#### **If you want to use SwiftCurrent without UIKit**

```swift
.product(name: "SwiftCurrent", package: "SwiftCurrent"),
```
#### **Your import statement in this case will be**


```swift
import SwiftCurrent
```
`Note:` When using SwiftCurrent for a custom domain, you will need to build out the associated [Orchestration Responders](https://wwt.github.io/SwiftCurrent/Protocols/OrchestrationResponder.html).

# CocoaPods

Set up [CocoaPods](https://cocoapods.org/) for your project, then include SwiftCurrent in your dependencies by adding one of the following lines to your `Podfile`:

#### **If you want to use SwiftCurrent with UIKit**

```ruby
pod 'SwiftCurrent/UIKit'
```

#### **If you want to use SwiftCurrent without UIKit**

```ruby
pod 'SwiftCurrent/Core'
```

`Note:` When using SwiftCurrent for a custom domain, you will need to build out the associated [Orchestration Responders](https://wwt.github.io/SwiftCurrent/Protocols/OrchestrationResponder.html).

#### **In both of these cases your import statement will be**

```swift
import SwiftCurrent
```
