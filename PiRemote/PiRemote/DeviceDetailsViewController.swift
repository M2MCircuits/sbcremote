//
//  DeviceDetailsViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 2/26/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

class DeviceDetailViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var pinTable: UITableView!

    // Local variables
    var pinConfig: [String: Int]!
    var pins: [Int: Pin]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        pinConfig? = ["SPI0": 0]
        pins = [0: Pin()]
        fetchDeviceState()
    }

    func fetchDeviceState() {
        guard MainUser.sharedInstance.currentDevice != nil else {
            return
        }

        let webiopi = WebAPIManager()
        webiopi.getFullGPIOState(callback: {
            data in
                if (data != nil) {
                    for (gpioNumber, gpioData) in data!["GPIO"] as! [String: [String:AnyObject]] {
                        let i = Int(gpioNumber)!
                        let pin = Pin().setFromData(gpioData)
                        self.pins[i] = pin
                    }
                    self.pinTable.reloadData()
                }
        })
    }


    // UITableViewDataSource Functions
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let i = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "PIN CELL", for: indexPath) as! PinTableViewCell

        guard (pins != nil) else {
            return cell
        }

        cell.nameLabel.text = pins[i]?.name
        cell.numberLabel.text = String(i)
        cell.statusSwitch.isOn = (pins[i]?.on)!
        cell.typeLabel.text = pins[i]?.function

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard (pins != nil) else {
            return 0
        }
        return self.pins.count
    }

}
