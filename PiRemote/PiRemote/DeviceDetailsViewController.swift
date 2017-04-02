//
//  DeviceDetailsViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 2/26/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

class DeviceDetailViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var pinTable: UITableView!

    // Local variables
    var pinConfig: [String: Int]!
    var pins: [Int: Pin]!
    var webiopi: WebAPIManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        deviceNameLabel.text = MainUser.sharedInstance.currentDevice?.deviceAlias
        pinConfig? = ["SPI0": 0]
        pins = [0: Pin()]
        webiopi = WebAPIManager()

        fetchDeviceState()
    }

    func fetchDeviceState() {
        guard MainUser.sharedInstance.currentDevice != nil else {
            return
        }

        print("[DEBUG] Sending get request /*")
        webiopi.getFullGPIOState(callback: {
            data in
                print("[DEBUG] Response received for /*")
                if (data != nil) {
                    for (gpioNumber, gpioData) in data!["GPIO"] as! [String: [String:AnyObject]] {
                        let i = Int(gpioNumber)!
                        let pin = Pin().setGPIONumber(i).setFromData(gpioData)
                        self.pins[i] = pin
                    }
                    self.pinTable.reloadData()
                }
        })
    }

    @IBAction func onToggleSwitch(_ sender: UISwitch) {
        let pinNumber = pins[sender.tag]?.gpioNumber
        let pinValue = sender.isOn ? "IN" : "OUT"
        webiopi.setFunction(gpioNumber: pinNumber!, functionType: pinValue, callback: {
                newFunction in
                    print("DONE")
                    print(newFunction!)
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
        cell.statusSwitch.tag = indexPath.row
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
