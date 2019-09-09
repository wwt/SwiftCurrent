![Build Status](https://img.shields.io/travis/com/Tyler-Keith-Thompson/Workflow.svg?style=popout) ![Pod Platform](https://img.shields.io/cocoapods/p/DynamicWorkflow.svg?style=popout) ![Pod Version](https://img.shields.io/cocoapods/v/DynamicWorkflow.svg?style=popout)

### Welcome to Workflow!
Workflow is a library meant to handle complex user flows in iOS applications.

#### Table of Contents:
- [Insallation](installation)
- [Why DynamicWorkflow?](why-this-library)
- [Getting Started](getting-started)
- [Testing Your Workflows](testing)
- [Advanced](advanced)
- [Developer Documentation](dev-docs)
- [FAQ](faq)

### The problem DynamicWorkflow was built to solve:
When developing for iOS one view controller has to know about the one following it in order to pass along daa. Imagine a workflow for a fast food app.

Pick a location -> Pickup or Delivery -> Catering Menu or Normal Menu -> Choose Food -> Review Order -> Submit payment

Now imagine if a users location is known via GPS. You may be able to skip the first screen and assume the nearest location knowing they can edit it on the review screen. Pickup or Delivery may or may not need to show up depending on what the location they picked supports, Same with catering menu vs normal menu

Finally the review screen would be really nice if it gave a way to edit. This spells a nightmare for you if you utilize UIStoryboardSegue to help. You'll have to use many of them, and if the design of this user flow changes you're in for a bit of an annoying time changing them around.


### The solution
DynamicWorkflow lets you specify once what the whole workflow looks like, then each view controller defines whether it should show up or not, so to solve the above problem you'd use something like this.

```swift
let workflow:Workflow = [
    LocationsViewController.self,
    PickupOrDeliveryViewController.self,
    MenuChooserViewController.self,
    FoodChooserViewController.self,
    ReviewOrderViewController.self,
    SubmitPaymentViewController.self
]

//from wherever this flow is launched
launchInto(workflow)
```

If you ever want to re-order these you simply move their position in the array. Your ViewControllers will be naturally start to become defined in a way where they can be injected into any kind of workflow and so if for scheduled orders you want screens to show up in a different order, you just define a new `Workflow`.
