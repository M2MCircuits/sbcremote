//
//  DevicesTableViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 2/25/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

class DevicesTableViewController: UITableViewController {

    // UITableViewDataSource Functions
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath) as! DeviceTableViewCell

        cell.deviceName.text = "Section: \(indexPath.section) Row: \(indexPath.row)"

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    // UITableViewDelegate Functions

}

