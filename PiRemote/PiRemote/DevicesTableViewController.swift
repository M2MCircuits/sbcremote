//
//  DevicesTableViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez, Victor Aniyah on 2/25/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
class DevicesTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate  {

    @IBOutlet var devicesTableView: UITableView!

    // MARK: Local Variables

    let cellId = "DEVICE CELL"
    var devices: [RemoteDevice]!
    var initialLogin : Bool = true

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
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(DevicesTableViewController.onLogout))
        let optionsButton = UIBarButtonItem(image: UIImage(named: "cog"), style: .plain, target: self, action: #selector(DevicesTableViewController.onShowActions))

        self.navigationItem.leftBarButtonItem = logoutButton
        self.navigationItem.rightBarButtonItem = optionsButton
        
        // API interaction
        self.appEngineManager = AppEngineManager()
        self.remoteManager = RemoteAPIManager()
        self.deviceManager = RemoteDeviceManager()
        self.webManager = WebAPIManager()

        // Pulling latest devices from Remote.it account
        self.present(OverlayManager.createLoadingSpinner(), animated: true, completion: nil)
        
        // Getting weaved token for the first time
        guard initialLogin == true else {
            self.fetchWeavedToken() { (token) in
                if token != nil{
                    self.fetchDevices(remoteToken: token!, completion: { (sucess) in
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                }
            }
            return
        }
        
        // Using weaved token from previous logins
        let remoteToken = MainUser.sharedInstance.weavedToken
        self.fetchDevices(remoteToken: remoteToken!) { (sucess) in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        } //TODO: remove these

        // Adding listeners for notifications from popovers
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleLoginSuccess), name: Notification.Name.loginSuccess, object: nil)

        self.devices = [RemoteDevice()]
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if segue.identifier == SegueTypes.idToDeviceDetails {
            (destination as! DeviceDetailsViewController).webAPI = self.webManager
        }
    }
  

    // MARK: UITableViewDataSource Functions

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! DeviceTableViewCell

        // Handling when waiting for api response
        cell.activityIndicator.stopAnimating()
        let device = devices[indexPath.row]

        guard device.apiData != nil else {
            cell.activityIndicator.startAnimating()
            cell.deviceNameLabel.text = "Getting device info..."
            cell.statusLabel.text = "?"
            return cell
        }

        cell.activityIndicator.isHidden = true
        cell.deviceNameLabel.text = device.apiData["deviceAlias"]
        cell.statusLabel.text = device.apiData["deviceState"] == "active" ? "On" : "Off"

        if device.apiData["deviceState"] != "active" {
            cell.deviceNameLabel.textColor = UIColor.lightGray
            cell.statusLabel.textColor = UIColor.lightGray
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices != nil ? devices.count : 0
    }

    // MARK: UITableViewDelegate Functions

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let device = devices[indexPath.row]

        // Preventing access to devices that are off
        guard device.apiData["deviceState"] == "active" else {
            return indexPath
        }

        let cell = devicesTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! DeviceTableViewCell

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

    // Prevents popover from changing style based on the iOS device
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    // MARK: Local Functions

    func fetchWeavedToken(completion: @escaping (_ token: String?)-> Void){
        let user = MainUser.sharedInstance
        guard user.email != nil, user.password != nil else{
            print("Critical failure. No username or password on file")
            return
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

    func fetchDevices(remoteToken : String, completion: @escaping(_ sucess: Bool) -> Void) {
        self.remoteManager.listDevices(token: remoteToken, callback: { data in
            guard data != nil else {
                // TODO: Use snackbar instead (requires refactoring this TableVC into a VC)
                print("There was a problem getting your devices")
                completion(false)
                return
            }

            self.devices = self.deviceManager.createDevicesFromAPIResponse(data: data!)

            // Sorting alphabetically. TODO: Does not work!
            self.devices = self.devices.sorted(by: {a,b in
                let nameA = a.apiData["deviceAlias"]!
                let nameB = a.apiData["deviceAlias"]!
                return nameA.compare(nameB) == ComparisonResult.orderedDescending
            })

            // Pushing non-sshdevices to app engine to create accounts
            // Optimization TODO : Only push new accounts. Save accounts and check if there are new ones.
            DispatchQueue.main.async {
                self.appEngineManager.createAccountsForDevices(devices: self.devices, email: MainUser.sharedInstance.email!, completion: { (sucess) in
                    completion(sucess)
                })
            }

            OperationQueue.main.addOperation {
                self.devicesTableView.reloadData()
            }
        })
    }

    func handleLoginSuccess() {
        // Supported by iOS <6.0
        self.performSegue(withIdentifier: SegueTypes.idToDeviceDetails, sender: self)
    }

    func onLogout(sender: UIButton!) {
        _ = self.navigationController?.popViewController(animated: true)

        //Removes all stored keys from keychain.
        let sucess = KeychainWrapper.standard.removeAllKeys()
        if !sucess{
            KeychainWrapper.standard.removeObject(forKey: "user_email")
            KeychainWrapper.standard.removeObject(forKey: "user_pw")
        }
        // TODO: Implement login info reset
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

