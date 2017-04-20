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
    var cellBeingLoggedInto: DeviceTableViewCell!
    let cellId = "DEVICE CELL"
    var devices: [RemoteDevice]!
    var initialLogin: Bool = true

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

        guard initialLogin == true else {
            // Getting weaved token for the first time
            self.fetchWeavedToken() { token in self.fetchDevices(with: token!)}
            return
        }

        // Using weaved token from previous logins // TODO: They are expired!!
        let remoteToken = MainUser.sharedInstance.weavedToken
        self.fetchDevices(with: remoteToken!)
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

        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! DeviceTableViewCell

        cell.activityIndicator.startAnimating()
        MainUser.sharedInstance.currentDevice = device

        // MARK: /device/connect


        self.present(OverlayManager.createLoadingSpinner(), animated: true, completion: nil)
        // Equivalent to whatsmyip.com
        cell.deviceNameLabel.text = "Locating device..."
        SimpleHTTPRequest().simpleAPIRequest(
            toUrl: "https://api.ipify.org?format=json", HTTPMethod: "GET", jsonBody: nil,
            extraHeaderFields: nil, completionHandler: { success, data, error in

                let deviceAddress = device.apiData!["deviceAddress"]!
                let senderAddress = (data as! NSDictionary)["ip"] as! String
                DispatchQueue.main.async {
                    cell.deviceNameLabel.text = "Connecting to device..."
                    RemoteAPIManager().connectDevice(deviceAddress: deviceAddress, hostip: senderAddress, completion: { data in
                        guard data != nil else{
                            print("Connect device returned nil")
                            self.present(OverlayManager.createErrorOverlay(message: "Something went wrong"), animated: true, completion: nil)
                            return
                        }

                        // Parsing url data returned from Remot3.it for WebIOPi
                        let connection = data!["connection"] as! NSDictionary
                        let domain = self.parseProxy(url: connection["proxy"] as! String)

                        DispatchQueue.main.async {
                            // Attempting to communicate with webiopi
                            cell.deviceNameLabel.text = "Getting data..."
                            self.webManager = WebAPIManager(ipAddress: domain, port: "", username: "webiopi", password: "webiopi")
                            self.webManager.getFullGPIOState(callback: { data in
                                //TODO: Error Handling :
                                guard data != nil else{
                                    print("gpio Data is nil")
                                    self.present(OverlayManager.createErrorOverlay(message: "Something went wrong"), animated: true, completion: nil)
                                    return
                                }
                                
                                
                                cell.activityIndicator.stopAnimating()
                                device.rawStateData = data as! [String: Any]
                                self.dismiss(animated: true, completion: {
                                    self.performSegue(withIdentifier: SegueTypes.idToDeviceDetails, sender: self)
                                })
                            }) // End WebIOPi call
                        }
                    })
                    // End Remot3.it call
                }
        }) // End whatsmyip call
        
        return indexPath
    }

    // MARK: UIPopoverPresentationControllerDelegate Functions

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Prevents popover from changing style based on the iOS device
        return .none
    }

    // MARK: Local Functions

    func fetchWeavedToken(completion: @escaping (_ token: String?)-> Void){
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
        self.present(alertController, animated: true, completion: nil)

        self.remoteManager.listDevices(token: token) { data in
            guard data != nil else {

                self.dismiss(animated: true, completion: nil)
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
}
