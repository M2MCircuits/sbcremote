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
class DeviceDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var powerStatusLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!

    // MARK: Local variables

    let cellId = "PIN CELL"
    var filters: [Pin.Types:String]!
    var filteredData: [Pin]!
    var webAPI: WebAPIManager!

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let currentDevice = MainUser.sharedInstance.currentDevice!
        let layoutName = "Custom-\(currentDevice.apiData["deviceAlias"]!)"

        if let data = UserDefaults.standard.object(forKey: "layoutNames") as? Data {
            let savedLayoutNames = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String]!
            if savedLayoutNames!.contains(layoutName) {
                // Loading previously saved layout for this device in order to restore names.
                let filePath = documentsDirectory().appending(layoutName)
                if let layout = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? PinLayout {
                    currentDevice.layout = layout
                }
            } else {
                // Creating new pin layout
                currentDevice.layout = PinLayout(name: layoutName, pins: [Pin]())
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false

        let currentDevice = MainUser.sharedInstance.currentDevice!

        filteredData = [Pin]()

        // Creating custom layout if not already defined
        DispatchQueue.main.async {
            self.refreshPinData() {pins in
                // Updating layout name label
                let deviceAlias = currentDevice.apiData["deviceAlias"]
                let layoutName = "Custom-\(deviceAlias!)"
                let moreDetailsLabels = self.stackView.arrangedSubviews[4].subviews as! [UILabel]
                moreDetailsLabels.filter({vw in vw.restorationIdentifier == "layoutName"}).first?.text = layoutName

                // TODO: Handle case where we're using a saved layout
                currentDevice.layout = PinLayout(name: layoutName, pins: pins!)

                // Refreshing table
                (self.stackView.arrangedSubviews[2] as! UITableView).reloadData()
            }
        }

        // Additional navigation setup
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(DeviceDetailsViewController.onBack))
        let optionsButton = UIBarButtonItem(image: UIImage(named: "cog"), style: .plain, target: self, action: #selector(DeviceDetailsViewController.onShowDeviceSetup))

        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = optionsButton

        // Configuring immediate info section
        deviceNameLabel.text = currentDevice.apiData["deviceAlias"]
        lastUpdatedLabel.text = formatTime(timestamp: currentDevice.lastUpdated)
        powerStatusLabel.backgroundColor = Theme.lightGreen300
        powerStatusLabel.clipsToBounds = true
        powerStatusLabel.layer.cornerRadius = powerStatusLabel.bounds.height / 2
        powerStatusLabel.textColor = Theme.grey900

        // Configuring table header section
        let filterButton = stackView.arrangedSubviews[1].subviews[3] as! UIButton
        let stencil = UIImage(named: "filter")?.withRenderingMode(.alwaysTemplate)
        filterButton.setImage(stencil, for: .normal)
        filterButton.tintColor = UIColor.gray

        // Configuring TableView section
        (stackView.arrangedSubviews[2] as! UITableView).rowHeight = 60

        // Configuring more details section
        stackView.arrangedSubviews[4].isHidden = true

        let labels = stackView.arrangedSubviews[4].subviews as! [UILabel]
        ["deviceAlias", "deviceLastIP", "lastInternalIP", "serviceTitle", "deviceAddress"].forEach({ key in
            labels.filter({vw in vw.restorationIdentifier == key}).first?.text = currentDevice.apiData[key]
        })

        // TODO: Add label for device persistance

        // Registering event listeners
        NotificationCenter.default
            .addObserver(self, selector: #selector(self.handleUpdatePin), name: Notification.Name.updatePin, object: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if segue.identifier == SegueTypes.idToDeviceSetup {
            (destination as! DeviceSetupViewController).webAPI = self.webAPI
        }
    }

    // MARK: UITableViewDataSource Functions

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PinTableViewCell
        let i = indexPath.row
        cell.tag = i
        cell.updateStyle(with: self.filteredData[i])
        cell.activityIndicator.isHidden = true
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }

    // MARK: UITableViewDelegate Functions

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }


    // MARK: UIPopoverPresentationControllerDelegate Functions

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Prevents popover from changing style based on the iOS device
        return UIModalPresentationStyle.none
    }

    // MARK: Local Functions

    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = paths[0] as String
        return documentDirectory
    }

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

    func getTableData() -> [Pin] {
        return MainUser.sharedInstance.currentDevice!.layout.pins
    }

    func handleUpdatePin(notification: Notification) {
        let userInfo = notification.userInfo as! [String:Any]
        let cell = userInfo["cell"] as! PinTableViewCell
        let pin = self.filteredData[cell.tag]

        // WebIOPi does not allow users to change non-GPIO pins
        guard pin.isGPIO() else {
            SharedSnackbar.show(parent: self.stackView, type: .warn, message: "You can only update GPIO pins")
            cell.reloadInputViews()
            return
        }

        let overlay = OverlayManager.createLoadingSpinner(withMessage: "Sending update...")
        DispatchQueue.main.async {
            self.present(overlay, animated: false)
        }

        // Handling API response failures
        let isResponseValid = { (data: Any?) -> Bool in
            guard data != nil else {
                SharedSnackbar.show(parent: self.stackView, type: .error, message: "Could not update pin")
                cell.reloadInputViews()
                return false
            }
            return true
        }

        let gpio = Int(pin.boardName.components(separatedBy: " ")[1])
        let value = (userInfo["value"]! as! String) == "true" ? 1 : 0

        self.webAPI.setValue(gpioNumber: gpio!, value: value) { newValue in
            DispatchQueue.main.async {
                guard isResponseValid(newValue) else {
                    self.dismiss(animated: false)
                    return
                }

                // Updating selected pin 
                MainUser.sharedInstance.currentDevice!.layout.pins.filter({p in
                    return p.id == pin.id
                }).first!.value = newValue! - 48

                cell.reloadInputViews()
                self.dismiss(animated: false)
            }
        }
    }

    func refreshPinData(completion: @escaping (_ pins: [Pin]?) -> Void) {
        let currentDevice = MainUser.sharedInstance.currentDevice!
        self.webAPI.getFullGPIOState() { data in
            DispatchQueue.main.async {
                guard data != nil else {
                    SharedSnackbar.show(parent: self.stackView, type: .error, message: "Could not refresh pins")
                    completion(nil)
                    return
                }
                
                currentDevice.rawStateData = data

                let gpioState = currentDevice.rawStateData["GPIO"] as! [String:NSDictionary]

                // Initializing pins from first 26 according to Pi Model B
                // TODO: Handle other pi versions.
                let pins = gpioState.map({ (pinBoardNumber, pinData) in
                    return Pin(id: Int(pinBoardNumber)!+1, apiData: pinData as! [String:AnyObject])
                }).sorted(by: {p1,p2 in return p1.id < p2.id})[0...25]

                // Preserving pin names if updated in DeviceSetupVC
                if currentDevice.layout != nil {
                    pins.forEach({p in
                        p.name = currentDevice.layout.pins[p.id-1].name
                        p.value = currentDevice.layout.pins[p.id-1].value
                        p.type = currentDevice.layout.pins[p.id-1].type
                    })
                }

                self.filteredData = pins
                    .filter({p in return p.type != .ignore})
                    .sorted(by: {p1,p2 in return p1.id < p2.id})
                    .sorted(by: {p1,p2 in return p1.type.rawValue > p2.type.rawValue})

                self.filters = [
                    .control: "Show",
                    .monitor: "Show",
                    .ignore: "Hide"
                ]

                completion(Array(pins))
            }
        }
    }

    func onBack() {
        _ = self.navigationController?.popViewController(animated: true)
    }

    func onShowDeviceSetup() {
        performSegue(withIdentifier: SegueTypes.idToDeviceSetup, sender: nil)
    }

    @IBAction func onShowFilterOptions(_ sender: UIButton) {
        let alert = UIAlertController(title: "Filter Options", message: "", preferredStyle: .actionSheet)
        let pins = MainUser.sharedInstance.currentDevice!.layout.pins

        self.filters.forEach({pinType, filter in
            let opposite = filter == "Show" ? "Hide" : "Show"
            let btnTitle = opposite + " " + String(describing: pinType) + " pins"
            let alertAction = UIAlertAction(title: btnTitle, style: .default, handler: { action in
                self.filters[pinType] = opposite
                self.filteredData = pins
                    .filter({p in return self.filters[p.type] == "Show" ? true : false})
                    .sorted(by: {p1,p2 in return p1.id < p2.id})
                    .sorted(by: {p1,p2 in return p1.type.rawValue > p2.type.rawValue})
                // Refreshing table
                (self.stackView.arrangedSubviews[2] as! UITableView).reloadData()
            })
            alert.addAction(alertAction)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        self.navigationController!.present(alert, animated: true)
    }


    @IBAction func onShowMoreDetails(_ sender: UIButton) {
        let isCurrentlyHidden = sender.titleLabel!.text!.contains("Show") as Bool
        let newTitle = isCurrentlyHidden ? "Hide More Details" : "Show More Details"
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                (self.stackView.arrangedSubviews[3] as! UIButton).titleLabel!.text = newTitle
                self.stackView.arrangedSubviews[4].isHidden = !isCurrentlyHidden
            })
        }
    }

}
