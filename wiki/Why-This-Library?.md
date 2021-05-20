### The problem Workflow was built to solve:
When developing for iOS one view controller has to know about the one following it in order to pass along data. Imagine a workflow for a fast food app.

Pick a location -> Pickup or Delivery -> Catering Menu or Normal Menu -> Choose Food -> Review Order -> Submit payment

Now imagine if a users location is known via GPS. You may be able to skip the first screen and assume the nearest location knowing they can edit it on the review screen. Pickup or Delivery may or may not need to show up depending on what the location they picked supports. The same is true with catering menu vs normal menu

Finally the review screen would be really nice if it gave a way to edit. This spells a nightmare for you if you utilize segues. You'll have to use many of them, and if the design of this user flow changes you're in for a bit of an annoying time changing them around.


### The solution
Workflow lets you specify once what the whole workflow looks like, then each view controller defines whether it should show up or not, so to solve the above problem you'd use something like this.

```swift
let workflow = Workflow(LocationsViewController.self)
                .thenPresent(PickupOrDeliveryViewController.self)
                .thenPresent(MenuChooserViewController.self)
                .thenPresent(FoodChooserViewController.self)
                .thenPresent(ReviewOrderViewController.self)
                .thenPresent(SubmitPaymentViewController.self)

// from wherever this flow is launched
launchInto(workflow)
```

If you ever want to re-order these you simply move their position in the chain. Your view controllers will naturally start to become defined in a way where they can be injected into any kind of workflow, and so if for scheduled orders you want screens to show up in a different order, you just define a new `Workflow`.
