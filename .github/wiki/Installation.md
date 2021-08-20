# Swift Package Manager

If you want more information about installing Swift packages through Xcode, [follow these instructions](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app). If you want to learn more about Swift Package Manager, [this page goes into detail](https://swift.org/package-manager/).

If you're a framework author and want to use SwiftCurrent as a dependency, update your `Package.swift` file.

## Get the package

Add the following line to the package dependencies

```swift
.package(url: "https://github.com/wwt/SwiftCurrent.git", .upToNextMajor(from: "4.0.0")),
```

## Get the products

Add the following products to your target dependencies.

```swift
.product(name: "SwiftCurrent", package: "SwiftCurrent"),
.product(name: "SwiftCurrent_UIKit", package: "SwiftCurrent")
.product(name: "BETA_SwiftCurrent_SwiftUI", package: "SwiftCurrent")
```

### Your import statements for these products will be

```swift
import SwiftCurrent
import SwiftCurrent_UIKit
import SwiftCurrent_SwiftUI // BETA
```

`SwiftCurrent_UIKit` will need to target a platform that supports UIKit, such as iOS or macOS with Catalyst.

[BETA] `SwiftCurrent_SwiftUI` requires the minimum versions of iOS 14.0, macOS 11, tvOS 14.0, or watchOS 7.0.

# CocoaPods

Set up [CocoaPods](https://cocoapods.org/) for your project, then include SwiftCurrent in your dependencies by adding the following line to your `Podfile`:

### To use SwiftCurrent with UIKit

```ruby
pod 'SwiftCurrent/UIKit'
```

### [BETA] To use SwiftCurrent with SwiftUI
```ruby
pod 'SwiftCurrent/BETA_SwiftUI'
```

### Your import statement will be

```swift
import SwiftCurrent
```
