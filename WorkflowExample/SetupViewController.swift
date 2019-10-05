//
//  SetupViewController.swift
//  WorkflowExample
//
//  Created by Tyler Thompson on 9/24/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import UIKit

class SetupViewController: UIViewController, StoryboardLoadable {
    @IBAction func launchMultiLocationWorkflow() {
        let locations = [
            Location(name: "Just Pickup w/ just catering",
                     address: Address(line1: "123 Fake St", line2: "", city: "Fakerton", state: "FK", zip: "00001"),
                     orderTypes: [OrderType.pickup],
                     menuTypes: [MenuType.catering]),
            Location(name: "Just Pickup w/ all menu types",
                     address: Address(line1: "123 Fake St", line2: "", city: "Fakerton", state: "FK", zip: "00001"),
                     orderTypes: [OrderType.pickup], menuTypes: [MenuType.catering, MenuType.regular]),
            Location(name: "Pickup And Delivery w/ just regular menu",
                     address: Address(line1: "567 Fake St", line2: "", city: "Fakerton", state: "FK", zip: "00003"),
                     orderTypes: [OrderType.pickup, OrderType.delivery(Address(line1: "", line2: "", city: "", state: "", zip: ""))],
                     menuTypes: [.regular]),
            Location(name: "Pickup And Delivery w/ all menu types",
                     address: Address(line1: "890 Fake St", line2: "", city: "Fakerton", state: "FK", zip: "00004"),
                     orderTypes: [OrderType.pickup, OrderType.delivery(Address(line1: "", line2: "", city: "", state: "", zip: ""))],
                     menuTypes: [.catering, .regular]),
        ]
        launchInto([
            LocationsViewController.self,
            PickupOrDeliveryViewController.self,
            MenuSelectionViewController.self,
            FoodSelectionViewController.self,
            ReviewOrderViewController.self,
        ], args: locations, withLaunchStyle: .navigationStack)
    }
}
