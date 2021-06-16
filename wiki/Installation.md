# Swift Package Manager

If you want more information about installing Swift packages through Xcode, [follow these instructions](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app). If you want to learn more about Swift Package Manager, [this page goes into detail](https://swift.org/package-manager/).

If you're a framework author and want to use SwiftCurrent as a dependency, update your `Package.swift` file.

## Get the package

Add the following line to the package dependencies

```swift
.package(url: "https://github.com/wwt/SwiftCurrent.git", .upToNextMajor(from: "4.0.0")),
```

## Get the correct product

Add the following products to your target dependencies.

#### **If you want to use SwiftCurrent with UIKit**

```swift
.product(name: "SwiftCurrent", package: "SwiftCurrent"),
.product(name: "SwiftCurrent_UIKit", package: "SwiftCurrent")
```

#### **Your import statements for these products will be**

```swift
import SwiftCurrent
import SwiftCurrent_UIKit
```

`SwiftCurrent_UIKit` will need to target a platform that supports UIKit, such as iOS or macOS with Catalyst.


# CocoaPods

Set up [CocoaPods](https://cocoapods.org/) for your project, then include SwiftCurrent in your dependencies by adding the following line to your `Podfile`:

#### **If you want to use SwiftCurrent with UIKit**

```ruby
pod 'SwiftCurrent/UIKit'
```

#### **Your import statement will be**

```swift
import SwiftCurrent
```
