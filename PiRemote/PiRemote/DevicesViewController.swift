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
    
    let sem = DispatchSemaphore(value: 0)

    let cellId = "DEVICE CELL"
    var devices: [RemoteDevice]!
    var deviceLastUpdated: String!
    var overlay: UIAlertController!
    var proxy: String!
    var isConnectionSuccess: Bool = false

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

        self.navigationItem.leftBarButtonItem = logoutButton

        // Adding listeners for notifications from popovers
        NotificationCenter.default.addObserver(self, selector: #selector(self.onLogin), name: .login, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onLoginSuccess), name: .loginSuccess, object: nil)

        self.devices = [RemoteDevice()]

        // API interaction
        self.appEngineManager = AppEngineManager()
        self.remoteManager = RemoteAPIManager()
        self.deviceManager = RemoteDeviceManager()
        self.webManager = WebAPIManager()

        // Showing overlay for fetching devices from Remot3.it
        overlay = OverlayManager.createLoadingSpinner(withMessage: "Gathering devices...")
        self.present(overlay, animated: true)

        // A new token is generated for each session. We always get a new one in case the previous token has expired.
        self.fetchToken() { token in
            guard token != nil else {
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.overlay = OverlayManager.createErrorOverlay(message: "Could not get token")
                        self.present(self.overlay, animated: true)
                    }
                }
                return
            }

            MainUser.sharedInstance.weavedToken = token
            self.fetchDevices(with: token!)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        switch segue.identifier! {
        case SegueTypes.idToDeviceDetails:
            (destination as! DeviceDetailsViewController).webAPI = self.webManager
        case SegueTypes.idToWebLogin:
            let dest = destination as! WebLoginViewController
            dest.domain = self.proxy
            let contentSize = CGSize(width: 300, height: 320)
            _ = PopoverViewController.buildPopover(
                source: self, content: destination, contentSize: contentSize, sourceRect: nil)
        default: break
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

        connectToDevice(device: device)
        
        return indexPath
    }

    // MARK: UIPopoverPresentationControllerDelegate Functions

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Prevents popover from changing style based on the iOS device
        return .none
    }

    // MARK: Local Functions

    func connectToDevice(device: RemoteDevice) {
        // TODO: Check if login has been saved and use it if so


            // Getting public IP address of user's phone or tablet
            let ipifyURL = "https://api.ipify.org?format=json"
            SimpleHTTPRequest().simpleAPIRequest(toUrl: ipifyURL, HTTPMethod: "GET", jsonBody: nil, extraHeaderFields: nil) {
                (success, data, error) in
                guard data != nil else{
                    DispatchQueue.main.async{
                    self.dismiss(animated: true, completion: { 
                        self.present(OverlayManager.createErrorOverlay(message: "Failed to connect:"), animated: true, completion: nil)
                        })
                    }
                    return
                }
                let deviceAddress = device.apiData!["deviceAddress"]!
                let senderAddress = (data as! NSDictionary)["ip"] as! String
                

            DispatchQueue.main.async{
                    
                RemoteAPIManager().connectDevice(deviceAddress: deviceAddress, hostip: senderAddress) { data in
                    self.isConnectionSuccess = data != nil

                    // Handling API response failure
                    guard self.isConnectionSuccess else {
                        self.sem.signal()
                        return
                    }

                    // Parsing url data returned from Remot3.it for WebIOPi
                    let connection = data!["connection"] as! NSDictionary
                    device.lastUpdated = connection["requested"] as! String
                    self.proxy = self.parseProxy(url: connection["proxy"] as! String)
                    self.sem.signal()
                    }
                }
            }
        if let data = checkIfDeviceLoginSaved(){
            NotificationCenter.default.post(name: Notification.Name.login, object: nil, userInfo: data)
        }else{
        // Presenting login dialog while we start sending API calls in the background
            self.performSegue(withIdentifier: SegueTypes.idToWebLogin, sender: self)
        }
    }
    
    
    func checkIfDeviceLoginSaved()->[String : Any]?{
        let deviceName = MainUser.sharedInstance.currentDevice!.apiData[DeviceAPIType.deviceAlias]
        let user = KeychainWrapper.standard.string(forKey: deviceName! + "user_name")
        let pw = KeychainWrapper.standard.string(forKey: deviceName! + "user_pw")
        if user != nil && pw != nil{
            return ["username" : user!,
            "password" : pw!, "save" : false] as [String : Any]
        }else{
            return nil
        }
    }

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
        self.remoteManager.listDevices(token: token) { data in
            guard data != nil else {
                self.dismiss(animated: true)
                return
            }

            self.devices = self.deviceManager.createDevicesFromAPIResponse(data: data!)

            // Optimization TODO : Only push new accounts. Save accounts and check if there are new ones.
            let userEmail = MainUser.sharedInstance.email!
            DispatchQueue.main.async {
                self.appEngineManager.createAccountsForDevices(devices: self.devices, email: userEmail, completion: {(success) in
                    if success{
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        
                        if appDelegate.accountOnRecord == false{
                          MainUser.sharedInstance.phone_token = appDelegate.registerForPushNotifications(UIApplication.shared)
                            MainUser.sharedInstance.savePhoneToken()
                        }
                        
                    }
                    
                })
            }

            // Hiding overlay
            OperationQueue.main.addOperation {
                (self.view.subviews[0] as! UITableView).reloadData()
                self.dismiss(animated: true)
            }
        }
    }

    func onLogin(notification: Notification) {
        let deviceName = MainUser.sharedInstance.currentDevice?.apiData!["deviceAlias"]!
        let user = notification.userInfo?["username"] as! String
        let pass = notification.userInfo?["password"] as! String
        let shouldSaveLogin = notification.userInfo?["save"] as! Bool
    
        let printError = {(message:String) in
            DispatchQueue.main.async {
                self.overlay = OverlayManager.createErrorOverlay(message: message)
                self.dismiss(animated: false) {
                    self.present(self.overlay, animated: true)
                }
            }
        }

        // Showing overlay for fetching devices from Remot3.it
        self.overlay = OverlayManager.createLoadingSpinner(withMessage: "Connecting to device...")
        self.present(overlay, animated: true) {

            // Uses semaphore to wait for signal from background thread. Much faster
            // Network timeout prevents hanging.
            _ = self.sem.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(5))

            guard self.isConnectionSuccess else {
                self.dismiss(animated: true, completion: { 
                    self.present(OverlayManager.createErrorOverlay(message: "Failed to connect to device"), animated: true, completion: nil)
                })
                printError("Could not connect to \(deviceName!)")
                return
            }

            DispatchQueue.main.async {
                self.overlay.message = "Logging in..."
            }

            self.webManager = WebAPIManager(ipAddress: self.proxy, port: "", username: user, password: pass)
            self.webManager.getValue(gpioNumber: 2) { value in
                DispatchQueue.main.async {
                    guard value != nil else {
                        printError("That login is incorrect")
                        return
                    }

                    if shouldSaveLogin{
                        KeychainWrapper.standard.set(user, forKey: deviceName! + "user_name")
                        KeychainWrapper.standard.set(pass, forKey: deviceName! + "user_pw")
                    }

                    self.dismiss(animated: true, completion: {() in
                        self.performSegue(withIdentifier: SegueTypes.idToDeviceDetails, sender: self)
                    })
                }
            }
        }
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

    func onLoginSuccess(notification: Notification) {
        self.performSegue(withIdentifier: SegueTypes.idToDeviceDetails, sender: self)
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
