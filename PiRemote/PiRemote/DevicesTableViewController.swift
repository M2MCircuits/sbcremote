//
//  DevicesTableViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 2/25/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

class DevicesTableViewController: UITableViewController {

    @IBOutlet var devicesTableView: UITableView!

    // Local Variables
    var sshDevices: [WeavedDevice]!
    var nonSshDevices: [WeavedDevice]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let weavedToken = MainUser.sharedInstance.token
        let weavedAPIManager = WeavedAPIManager()
        let deviceManager = WeavedDeviceManager()
        self.sshDevices = [WeavedDevice()]
        self.nonSshDevices = [WeavedDevice()]
        weavedAPIManager.listDevices(token: weavedToken!, callback: {
            data in
                guard data != nil else {
                    return
                }
                (self.sshDevices!, self.nonSshDevices!) = deviceManager.createDevicesFromAPIResponse(data: data!)
                OperationQueue.main.addOperation {
                    self.devicesTableView.reloadData()
                }
        })
    }

    // UITableViewDataSource Functions
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DEVICE CELL", for: indexPath) as! DeviceTableViewCell

        // Debugging purposes only
        cell.deviceName.text = "Section: \(indexPath.section) Row: \(indexPath.row)"

        guard sshDevices != nil else {
            return cell
        }
        guard nonSshDevices != nil else {
            return cell
        }

        let allDevices = sshDevices + nonSshDevices
        cell.deviceName.text = allDevices[indexPath.row].alias
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sshDevices.count + nonSshDevices.count;
    }

    // UITableViewDelegate Functions

}

