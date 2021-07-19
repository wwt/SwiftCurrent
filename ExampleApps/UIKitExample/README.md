#  About UIKitExample

## Overview
The app is designed to give you an idea of what SwiftCurrent can do with minimal overhead in the UI. The key areas of code you'll want to look at are: `SetupViewController.swift` and the view controllers referenced in the `Workflow`.

We have exhaustive developer documentation on SwiftCurrent, and that documentation should be referenced for any questions regarding types, functions, and parameters.  This README will focus on how this example app is structured.  

## Starting Controllers
### SetupViewController
#### Overview
The `SetupViewController` is the starting point of the app.  It launches the ordering workflow.  

## Order workflow controllers
Unless otherwise stated, all view controllers in the order workflow are:

- Have a `WorkflowInput` type of `Order` and a `WorkflowOutput` type of `Order`.
- A `FlowRepresentable`.
- Loaded from the `Main.storyboard`.


### LocationsViewController
#### Overview
The `LocationsViewController` allows users to select which location from which they want to start their order.  It contains a list of locations, and upon selecting a location the view controller will create an `Order` with that location and passes the new `Order` to the next screen.

#### SwiftCurrent related details
`LocationsViewController` has an `WorkflowInput` type of `[Location]` and a `WorkflowOutput` type of `Order`.

This view only loads if there is more than 1 `Location` to select.  If there is only 1 `Location`, that `Location` is automatically used to create a new `Order` and we move to the next screen.

### PickupOrDeliveryViewController
#### Overview
The `PickupOrDeliveryViewController` allows users to select an order type such as pickup or delivery.  If the order is a delivery type, a new workflow is launched to gather the user's address before moving to the next screen. 

#### SwiftCurrent related details
This view only loads if there is more than 1 `OrderType` available at the given location.  If there is only 1 `OrderType` then that is automatically applied to the `Order` and we move to the next screen.

This view offers an example of launching a `Workflow` in a `Workflow`.

### MenuSelectionViewController
#### Overview

#### SwiftCurrent related details


### FoodSelectionViewController
#### Overview
The `FoodSelectionViewController` allows users to select their food options.  It presents 3 hardcoded options that are added to the order before moving to the next screen.

#### SwiftCurrent related details
This view always loads.


### ReviewOrderViewController
#### Overview

#### SwiftCurrent related details
