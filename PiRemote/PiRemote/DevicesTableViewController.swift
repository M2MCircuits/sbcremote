//
//  DevicesTableViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 2/25/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

class DevicesTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate  {

    @IBOutlet var devicesTableView: UITableView!

    // Local Variables
    let cellId = "DEVICE CELL"

    var dialogMessage: String!
    var sshDevices: [RemoteDevice]!
    var nonSshDevices: [RemoteDevice]!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Additional navigation setup
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(DevicesTableViewController.logout))

        self.navigationItem.leftBarButtonItem = logoutButton
        
        let appEngineAPI = AppEngineManager()

        // Add listeners for notifications from popovers
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleLoginSuccess), name: Notification.Name.loginSuccess, object: nil)

        // Pull latest devices from Remote.it account
        let remoteToken = MainUser.sharedInstance.weavedToken
        let remoteAPIManager = RemoteAPIManager()
        let deviceManager = RemoteDeviceManager()

        self.sshDevices = [RemoteDevice()]
        self.nonSshDevices = [RemoteDevice()]
        remoteAPIManager.listDevices(token: remoteToken!, callback: {
            data in
                guard data != nil else {
                    return
                }
                (self.sshDevices!, self.nonSshDevices!) = deviceManager.createDevicesFromAPIResponse(data: data!)
                // We push non-sshdevices to app engine to create accounts
                DispatchQueue.main.async {
                       appEngineAPI.createAccountsForDevices(devices: self.nonSshDevices, email: MainUser.sharedInstance.email!, completion: { (sucess) in
                        if sucess{
                            print("Suceeded in creating accounts for user")
                        }else{
                            print("Failed to create devices")
                        }
                    })
                }
            
                OperationQueue.main.addOperation {
                    self.devicesTableView.reloadData()
                }
        })

        dialogMessage = "Enter login for this devices WebIOPi server."
    }

    // UITableViewDataSource Functions
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! DeviceTableViewCell

        // Debugging purposes only
        cell.deviceName.text = "Section: \(indexPath.section) Row: \(indexPath.row)"

        guard sshDevices != nil else {
            return cell
        }

        guard nonSshDevices != nil else {
            return cell
        }

        let allDevices = sshDevices + nonSshDevices
        guard allDevices[indexPath.row].apiData != nil else {
            return cell
        }

        cell.deviceName.text = allDevices[indexPath.row].apiData["deviceAlias"]
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sshDevices.count + nonSshDevices.count;
    }

    // UITableViewDelegate Functions
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let allDevices = sshDevices + nonSshDevices
        let device = allDevices[indexPath.row]
        MainUser.sharedInstance.currentDevice = device

        // Equivalent to whatsmyip.com
        SimpleHTTPRequest().simpleAPIRequest(toUrl: "https://api.ipify.org?format=json", HTTPMethod: "GET", jsonBody: nil, extraHeaderFields: nil, completionHandler: { success, data, error in
            let deviceAddress = device.apiData["deviceAddress"]!
            let senderAddress = (data as! NSDictionary)["ip"] as! String

            // Post to get device connection
            RemoteAPIManager().connectDevice(deviceAddress: deviceAddress, hostip: senderAddress, shouldWait: true, callback: { data in

                let connection = data!["connection"] as! NSDictionary
                let proxyUrl = connection["proxy"] as! String

                let start = proxyUrl.range(of: "http://")?.upperBound
                let end = proxyUrl.range(of: "com")?.upperBound

                let domain = proxyUrl.substring(with: start!..<end!)
                let port = proxyUrl.substring(from: (proxyUrl.range(of: "com:")?.upperBound)!)

                // Attempting to communicate with webiopi
                let webapi = WebAPIManager(ipAddress: domain, port: port, username: "webiopi", password: "raspberry")
                webapi.getFullGPIOState(callback: { data in
                    print(data!)
                })
            })
        })

        return indexPath
    }

    // Prevents popover from changing style based on the iOS device
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    // Local Functions
    func handleLoginSuccess() {
        // Supported by iOS <6.0
        self.performSegue(withIdentifier: SegueTypes.idToDeviceDetails, sender: self)
    }

    func logout(sender: UIButton!) {
        _ = self.navigationController?.popViewController(animated: true)
        // TODO: Implement login info reset
    }
}

