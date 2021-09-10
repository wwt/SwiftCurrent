SwiftCurrent allows you to control how your workflow presents its `FlowRepresentable`s. This control over presentation is different for UIKit and SwiftUI. You can also control `FlowPersistence` which is a description for what should happen to an item in a `workflow` if it's been skipped, or once the workflow has proceeded. 

### UIKit
In UIKit you control presentation using `LaunchStyle.PresentationType`. The default is a contextual presentation mode. If it detects you are in a navigation view, it'll present by pushing onto the navigation stack. If it cannot detect a navigation view it presents modally. Alternatively you can explicitly state you'd like it to present modally or in a navigation stack when you define your `workflow`.

### In SwiftUI
In SwiftUI you control presentation using `LaunchStyle.SwiftUI.PresentationType`. The default is simple view replacement. This is especially powerful because your workflows in SwiftUI do not need to be an entire screen, they can be just part of a view. Using the default presentation type you can also get fine grained control over animations. You can also explicitly state you'd like it to present modally (using a sheet, or fullScreenCover) or in a navigation stack when you define your `WorkflowLauncher`.

### Persistence
You can control what happens to items in your workflow using `FlowPersistence`. Using `FlowPersistence.persistWhenSkipped` means that when `FlowRepresentable.shouldLoad` returns false the item is still stored on the workflow. If for example, you're in a navigation stack this means the item *is* skipped, but you can back up to it. 

using `FlowPersistence.removedAfterProceeding` means once the `workflow` has proceeded, the item is removed, references to it are cleaned up, and it is removed from any back stacks.