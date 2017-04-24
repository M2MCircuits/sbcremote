//
//  DeviceDetailsViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 2/26/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

// TODO: Add sorting feature by type and status
@available(iOS 9.0, *)
class DeviceDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var powerStatusLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!

    // MARK: Local variables

    var currentSelection: PinTableViewCell!
    var device: RemoteDevice!
    var webAPI: WebAPIManager!

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false

        device = MainUser.sharedInstance.currentDevice!

        // Creating custom layout if not already defined
        if device.layout == nil {
            self.initCustomLayout(for: device)
        }

        // Additional navigation setup
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(DeviceDetailsViewController.onBack))
        let setupButton = UIBarButtonItem(image: UIImage(named: "cog"), style: .plain, target: self, action: #selector(DeviceDetailsViewController.onViewSetup))

        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = setupButton

        // Configuring title section
        (stackView.arrangedSubviews[0] as! UILabel).text = device.apiData["deviceAlias"]

        // Configuring immediate info section
        powerStatusLabel.backgroundColor = Theme.lightGreen300
        powerStatusLabel.clipsToBounds = true
        powerStatusLabel.layer.cornerRadius = 16
        powerStatusLabel.textColor = Theme.grey900

        // TODO: Update last updated time

        // Configuring table view section
        (stackView.arrangedSubviews[3] as! UITableView).rowHeight = 68

        // Configuring more details section
        stackView.arrangedSubviews[5].isHidden = true

        let labels = stackView.arrangedSubviews[5].subviews as! [UILabel]
        ["deviceAlias", "deviceLastIP", "lastInternalIP", "serviceTitle", "deviceAddress"].forEach({ key in
            labels.filter({vw in vw.restorationIdentifier == key}).first?.text = device.apiData[key]
        })

        // TODO: Add label for device persistance

        // Registering event listeners
        NotificationCenter.default
            .addObserver(self, selector: #selector(self.handleUpdatePin), name: Notification.Name.updatePin, object: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if segue.identifier == SegueTypes.idToDeviceSetup {
            (destination as! DeviceSetupViewController).pinLayout = device.layout
        }
    }

    // MARK: UITableViewDataSource Functions

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PIN CELL", for: indexPath) as! PinTableViewCell
        let i = indexPath.row

        cell.updateStyle(with: device.layout.defaultSetup[i])

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return device.layout != nil ? device.layout.defaultSetup.count : 0
    }

    // MARK: UITableViewDelegate Functions

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PIN CELL", for: indexPath) as! PinTableViewCell
        cell.tag = indexPath.row
        self.currentSelection = cell
        return indexPath
    }

    // MARK: Local Functions

    func handleUpdatePin(notification: Notification) {
        let userInfo = notification.userInfo as! [String:String]
        let id = Int(userInfo["id"]!)!

        let tableView = stackView.arrangedSubviews[3] as! UITableView
        let indexPath = IndexPath(row: id, section: 0)
        self.currentSelection = tableView.dequeueReusableCell(withIdentifier: "PIN CELL", for: indexPath) as! PinTableViewCell

        if userInfo.keys.contains("value") {
            let value = userInfo["value"]! == "true" ? 1 : 0
            webAPI.setValue(gpioNumber: id, value: value, completion: { newValue in
                // TODO: Handle nil = failure
                print(newValue!)
                let pin = self.device.layout.defaultSetup[id]
                pin.value = newValue!
                self.currentSelection.updateStyle(with: pin)
            })
        } else if userInfo.keys.contains("function") {
            let function = userInfo["function"]! == "Control" ? "out" : "in"
            webAPI.setFunction(gpioNumber: id, functionType: function, completion: { newFunction in
                print(newFunction!)
                // TODO: Handle nil = failure
                let pin = self.device.layout.defaultSetup[id]
                pin.function = newFunction!
                self.currentSelection.updateStyle(with: pin)
            })
        }
    }

    func initCustomLayout(for device: RemoteDevice) {
        let deviceAlias = device.apiData["deviceAlias"]

        DispatchQueue.main.async {
            self.webAPI.getFullGPIOState() { data in
                OperationQueue.main.addOperation {
                    device.rawStateData = data

                    let gpioState = device.rawStateData["GPIO"] as! [String:NSDictionary]
                    let pins = gpioState.map({ (pinBoardNumber, pinData) in
                        return Pin(id: Int(pinBoardNumber)!, apiData: pinData as! [String : AnyObject])
                    }).sorted(by: {p1,p2 in p1.id < p2.id})

                    // TODO: Handle other pi versions
                    device.layout = PinLayout(name: "Custom-\(deviceAlias!)", defaultSetup: Array(pins[0...25]))

                    // Updating layout label in more details section
                    let moreDetailsLabels = self.stackView.arrangedSubviews[5].subviews as! [UILabel]
                    moreDetailsLabels.filter({vw in vw.restorationIdentifier == "layoutName"}).first?.text = device.layout.name

                    // Refreshing table
                    (self.stackView.arrangedSubviews[3] as! UITableView).reloadData()
                }
            }
        }
    }

    func onBack() {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onShowMoreDetails(_ sender: UIButton) {
        let isCurrentlyHidden = sender.titleLabel!.text!.contains("Show") as Bool
        let newTitle = isCurrentlyHidden ? "Hide More Details" : "Show More Details"
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                (self.stackView.arrangedSubviews[4] as! UIButton).titleLabel!.text = newTitle
                self.stackView.arrangedSubviews[5].isHidden = !isCurrentlyHidden
            }, completion: nil)
        }
    }

    func onViewSetup() {
        // TODO: Add actionsheet with options: [Show Setup, Filter By, ] 
        // Supported by iOS <6.0
        self.performSegue(withIdentifier: SegueTypes.idToDeviceSetup, sender: self)
    }

}
