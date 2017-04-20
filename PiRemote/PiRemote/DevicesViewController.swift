//
//  DevicesViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez, Victor Aniyah on 2/25/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
class DevicesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate  {

    // MARK: Local Variables

    var alertController: UIAlertController!
    let cellId = "DEVICE CELL"
    var devices: [RemoteDevice]!
    
    var appEngineManager : AppEngineManager!
    var deviceManager : RemoteDeviceManager!
    var remoteManager : RemoteAPIManager!
    var webManager : WebAPIManager!

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting up navigation bar
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(DevicesViewController.onLogout))
        let optionsButton = UIBarButtonItem(image: UIImage(named: "cog"), style: .plain, target: self, action: #selector(DevicesViewController.onShowActions))

        self.navigationItem.leftBarButtonItem = logoutButton
        self.navigationItem.rightBarButtonItem = optionsButton

        // Adding listeners for notifications from popovers
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleLoginSuccess), name: Notification.Name.loginSuccess, object: nil)

        self.devices = [RemoteDevice()]

        // API interaction
        self.appEngineManager = AppEngineManager()
        self.remoteManager = RemoteAPIManager()
        self.deviceManager = RemoteDeviceManager()
        self.webManager = WebAPIManager()

        // A new token is generated for each session. We always get a new one in case the previous token has expired.
        self.fetchToken() { token in
            MainUser.sharedInstance.weavedToken = token
            self.fetchDevices(with: token!)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if segue.identifier == SegueTypes.idToDeviceDetails {
            (destination as! DeviceDetailsViewController).webAPI = self.webManager
        }
    }

    // MARK: UITableViewDataSource Functions

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! DeviceTableViewCell
        let device = devices[indexPath.row]

        // Handling case when waiting for API response
        guard device.apiData != nil else {
            return cell
        }

        // Styling based on API data
        cell.activityIndicator.isHidden = true
        cell.deviceNameLabel.text = device.apiData["deviceAlias"]
        cell.statusLabel.text = device.apiData["deviceState"] == "active" ? "On" : "Off"

        if device.apiData["deviceState"] != "active" {
            cell.deviceNameLabel.textColor = UIColor.lightGray
            cell.statusLabel.textColor = UIColor.lightGray
        }

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices != nil ? devices.count : 0
    }

    // MARK: UITableViewDelegate Functions

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let device = devices[indexPath.row]

        // Preventing access to devices that are off
        guard device.apiData["deviceState"] == "active" else {
            return indexPath
        }

        MainUser.sharedInstance.currentDevice = device

        validateLoginCredentials()
        
        return indexPath
    }

    // MARK: UIPopoverPresentationControllerDelegate Functions

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Prevents popover from changing style based on the iOS device
        return .none
    }

    // MARK: Local Functions

    func fetchToken(completion: @escaping (_ token: String?)-> Void) {
        let user = MainUser.sharedInstance
        guard user.email != nil, user.password != nil else {
            fatalError("[ERROR] Critical failure. No username or password on file")
        }

        self.remoteManager.logInUser(username: user.email!, userpw: user.password!) { (sucess, response, data) in
            guard data != nil else{
                completion(nil)
                return
            }
            let weaved_token = data!["token"] as! String
            completion(weaved_token)
        }
    }

    func fetchDevices(with token : String) {
        // Showing overlay for fetching devices from Remot3.it
        alertController = OverlayManager.createLoadingSpinner(withMessage: "Gathering devices...")
        self.present(alertController, animated: true)

        self.remoteManager.listDevices(token: token) { data in
            guard data != nil else {
                self.dismiss(animated: true)
                return
            }

            self.devices = self.deviceManager.createDevicesFromAPIResponse(data: data!)

            // Optimization TODO : Only push new accounts. Save accounts and check if there are new ones.
            let userEmail = MainUser.sharedInstance.email!
            DispatchQueue.main.async {
                self.appEngineManager.createAccountsForDevices(devices: self.devices, email: userEmail, completion: nil)
            }

            // Hiding overlay
            OperationQueue.main.addOperation {
                (self.view.subviews[0] as! UITableView).reloadData()
                self.dismiss(animated: true)
            }
        }
    }

    func handleLoginSuccess() {
        // Supported by iOS <6.0
        self.performSegue(withIdentifier: SegueTypes.idToDeviceDetails, sender: self)
    }

    func onLogout(sender: UIButton!) {
        _ = self.navigationController?.popViewController(animated: true)

        // Removing all stored keys from keychain.
        let sucess = KeychainWrapper.standard.removeAllKeys()
        if !sucess {
            KeychainWrapper.standard.removeObject(forKey: "user_email")
            KeychainWrapper.standard.removeObject(forKey: "user_pw")
        }
    }

    func onShowActions() {
        // TODO: Implement. show action sheet (show ssh, layouts, refresh)
    }

    func parseProxy(url: String) -> String {
        guard url.contains("com") else {
            fatalError("[Error] Proxy returned an unexpected domain name")
        }

        let start = url.range(of: "https://")?.upperBound
        let end = url.range(of: "com")?.upperBound
        let domain = url.substring(with: start!..<end!)

        return domain
    }

    func validateLoginCredentials() {
        let updateProgress = { message in
            DispatchQueue.main.async {
                self.alertController.message = message
            }
        }

        // Showing overlay for fetching devices from Remot3.it
        self.alertController = OverlayManager.createLoadingSpinner()
        self.present(alertController, animated: true)

        updateProgress("Locating device...")

        // Getting public IP address of user's phone or tablet
        let ipifyURL = "https://api.ipify.org?format=json"
        SimpleHTTPRequest().simpleAPIRequest(toUrl: ipifyURL, HTTPMethod: "GET", jsonBody: nil, extraHeaderFields: nil) {
            (success, data, error) in
            let device = MainUser.sharedInstance.currentDevice!
            let deviceAddress = device.apiData!["deviceAddress"]!
            let senderAddress = (data as! NSDictionary)["ip"] as! String

            updateProgress("Connecting to device...")

            RemoteAPIManager().connectDevice(deviceAddress: deviceAddress, hostip: senderAddress) { data in
                // Handling API response failure
                guard data != nil else {
                    let errorOverlay = OverlayManager.createErrorOverlay(message: "Could not connect to \(device.apiData!["deviceAlias"]!)")
                    self.dismiss(animated: false)
                    self.present(errorOverlay, animated: false)
                    return
                }

                // Parsing url data returned from Remot3.it for WebIOPi
                let connection = data!["connection"] as! NSDictionary
                let domain = self.parseProxy(url: connection["proxy"] as! String)

                updateProgress("Getting data...")

                // Attempting to communicate with webiopi, first with a default login
                // TODO: Persists login for each device

                self.webManager = WebAPIManager(ipAddress: domain, port: "", username: "webiopi", password: "webiopi")
                self.webManager.getValue(gpioNumber: 2) { value in
                    // Requesting user to sign in manually if default login fails
                    guard value != nil else {
                        print("ruh-roh")
                        return
                    }
                    print(value!)

                    // Hiding overlay
                    self.dismiss(animated: true) {
                        self.performSegue(withIdentifier: SegueTypes.idToDeviceDetails, sender: self)
                    }
                } // End WebIOPi call
            } // End Remot3.it call
        } // End whatsmyip call
    }
}
