//
//  LocationsViewController.swift
//  WorkflowExample
//
//  Created by Tyler Thompson on 9/24/19.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//

import Foundation
import Workflow
import WorkflowUIKit
import UIKit

class LocationsViewController: UIWorkflowItem<[Location], Order>, StoryboardLoadable {
    @IBOutlet private weak var tableView: UITableView!

    var locations: [Location] = []
}

extension LocationsViewController: FlowRepresentable {
    func shouldLoad(with locations: [Location]) -> Bool {
        self.locations = locations
        if let location = locations.first,
            locations.count == 1 {
            proceedInWorkflow(Order(location: location))
        }
        return locations.count > 1
    }
}

extension LocationsViewController: UITableViewDataSource, UITableViewDelegate {
    struct Identifiers {
        static let cellReuse = "locationsCell"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.cellReuse, for: indexPath)
        let location = locations[indexPath.row]
        cell.textLabel?.text = location.name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = locations[indexPath.row]
        let order = Order(location: location)
        proceedInWorkflow(order)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
