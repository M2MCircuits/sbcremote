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

    let cellId = "PIN CELL"
    var currentCell: PinTableViewCell!
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
        lastUpdatedLabel.text = formatTime(timestamp: device.lastUpdated)
        powerStatusLabel.backgroundColor = Theme.lightGreen300
        powerStatusLabel.clipsToBounds = true
        powerStatusLabel.layer.cornerRadius = 16
        powerStatusLabel.textColor = Theme.grey900

        // TODO: Update last updated time

        // Configuring table view section
        (stackView.arrangedSubviews[3] as! UITableView).rowHeight = 60

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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PinTableViewCell
        let i = indexPath.row

        cell.updateStyle(with: device.layout.defaultSetup[i])
        cell.activityIndicator.isHidden = true
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PinTableViewCell
        cell.tag = indexPath.row
        self.currentCell = cell
        return indexPath
    }

    // MARK: Local Functions

    func formatTime(timestamp: String) -> String {
        // example from weaved: "4/24/2017T10:49 AM"
        // TODO: Account for timezones, weaved returns EST (-5)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"

        let parts = timestamp.components(separatedBy: "T")
        let requestDate = dateFormatter.date(from: parts[0].characters.count == 10 ? parts[0] : "0" + parts[0])

        let currentDate = Date()
        let is24HoursAgo = currentDate.timeIntervalSince(requestDate!) < 1440000

        return is24HoursAgo ? parts[1] + " (EST)" : parts[0]
    }

    func handleUpdatePin(notification: Notification) {
        let userInfo = notification.userInfo as! [String:Any]
        let id = userInfo["id"] as! Int
        let indexPath = IndexPath(row: id-1, section: 0)
        let currentPin = self.device.layout.defaultSetup[id-1]
        let tableView = stackView.arrangedSubviews[3] as! UITableView

        // WebIOPi does not allow users to change non-GPIO pins
        guard currentPin.isGPIO() else {
            SharedSnackbar.show(parent: self.stackView, type: .warn, message: "You can only update GPIO pins")
            tableView.reloadRows(at: [indexPath], with: .automatic)
            return
        }

        // Handling API response failures
        let isResponseValid = { (data: Any?) -> Bool in
            guard data != nil else {
                SharedSnackbar.show(parent: self.stackView, type: .error, message: "Could not update pin")
                tableView.reloadRows(at: [indexPath], with: .automatic)
                return false
            }
            return true
        }

        DispatchQueue.main.async {
            let gpio = Int(currentPin.boardName.components(separatedBy: " ")[1])
            self.currentCell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath) as! PinTableViewCell

            if userInfo.keys.contains("value") {
                let value = (userInfo["value"]! as! String) == "true" ? 1 : 0
                self.webAPI.setValue(gpioNumber: gpio!, value: value) { newValue in
                    OperationQueue.main.addOperation {
                        guard isResponseValid(newValue) else { return }
                        currentPin.value = newValue! - 48
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            } else if userInfo.keys.contains("type") {
                let function = (userInfo["type"]! as! Pin.Types) == .control ? "out" : "in"
                self.webAPI.setFunction(gpioNumber: gpio!, functionType: function) { newFunction in
                    OperationQueue.main.addOperation {
                        guard isResponseValid(newFunction) else { return }
                        currentPin.function = newFunction!
                        currentPin.type = userInfo["type"]! as! Pin.Types
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
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
