//
//  DeviceDetailsViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 2/26/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

class DeviceDetailsViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var pinTable: UITableView!

    // Local variables
    var pinConfig: [String: Int]!
    var pins: [Int: Pin]!
    var webiopi: WebAPIManager!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let deviceName = MainUser.sharedInstance.currentDevice?.apiData["deviceAlias"]

        // Additional navigation setup
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(DeviceDetailsViewController.onCancel))
        let setupButton = UIBarButtonItem(image: UIImage(named: "cog"), style: .plain, target: self, action: #selector(DeviceDetailsViewController.onViewSetup))

        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = setupButton
        self.navigationItem.title = String(format: "%@ Info", deviceName!)
        
        // Initialize pin list
        pinConfig? = ["SPI0": 0]
        pins = [Int:Pin]()
        for i in 1...40 { pins[i] = (Pin(id: i)) }

        webiopi = WebAPIManager()

        fetchDeviceState()
        self.pinTable.reloadData()
    }


    @IBAction func onToggleSwitch(_ sender: UISwitch) {
        let pinNumber = pins[sender.tag]?.id
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
        cell.statusSwitch.isOn = (pins[i]?.value == 1)
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

    // Local Functions
    func buildPins() {
        let stateJson = MainUser.sharedInstance.currentDevice!.stateJson
        for (pinId, pinData) in stateJson! {
            let i = Int(pinId)!
            let pin = Pin(id: i, apiData: pinData)
            self.pins[i] = pin
        }
    }

    func fetchDeviceState() {
        guard MainUser.sharedInstance.currentDevice?.stateJson != nil else {
            print("[DEBUG] Sending get request /*")

            webiopi.getFullGPIOState(callback: { data in
                print("[DEBUG] Response received for /*")

                if (data != nil) {
                    MainUser.sharedInstance.currentDevice!.stateJson = data!["GPIO"] as! [String: [String:AnyObject]]
                    self.buildPins()
                }
            })

            return
        }

        self.buildPins()
    }

    func onCancel() {
        self.navigationController?.popViewController(animated: true)
    }

    func onViewSetup() {
        // Supported by iOS <6.0
        self.performSegue(withIdentifier: SegueTypes.idToDeviceSetup, sender: self)
    }

}
