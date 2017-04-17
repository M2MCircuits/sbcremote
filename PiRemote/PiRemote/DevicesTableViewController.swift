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

    var initialLogin : Bool = true
    // Local Variables
    let cellId = "DEVICE CELL"

    var deviceManager : RemoteDeviceManager!
    var remoteManager : RemoteAPIManager!
    var appEngineManager : AppEngineManager!
    
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
        
        self.appEngineManager = AppEngineManager()

        // Add listeners for notifications from popovers
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleLoginSuccess), name: Notification.Name.loginSuccess, object: nil)


        self.remoteManager = RemoteAPIManager()
        self.deviceManager = RemoteDeviceManager()

        self.sshDevices = [RemoteDevice()]
        self.nonSshDevices = [RemoteDevice()]
        
        guard initialLogin == true else{
            self.fetchWeavedToken() { (token) in
                if token != nil{
                    self.fetchDevices(remoteToken: token!, completion: { (sucess) in })
                }
            }
            return
        }
        
        // Pull latest devices from Remote.it account
        let remoteToken = MainUser.sharedInstance.weavedToken
        self.fetchDevices(remoteToken: remoteToken!) { (sucess) in //TODO: remove these
        }

        
        dialogMessage = "Enter login for this devices WebIOPi server."
    }

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
    
    func fetchDevices(remoteToken : String, completion: @escaping(_ sucess: Bool)->Void){
        self.remoteManager.listDevices(token: remoteToken, callback: {
            data in
            guard data != nil else {
                completion(false)
                return
            }
            (self.sshDevices!, self.nonSshDevices!) = self.deviceManager.createDevicesFromAPIResponse(data: data!)
            
            // We push non-sshdevices to app engine to create accounts
            // Optimization TODO : Only push new accounts. Save accounts and check if there are new ones.
            DispatchQueue.main.async {
                self.appEngineManager.createAccountsForDevices(devices: self.nonSshDevices, email: MainUser.sharedInstance.email!, completion: { (sucess) in
                    
                    if (self.initialLogin){
                    //Registers for notification now that the user information is there.
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.registerForPushNotifications(UIApplication.shared)
                    }
                    completion(sucess)
                })
            }
            
            OperationQueue.main.addOperation {
                self.devicesTableView.reloadData()
            }
        })

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
        let vc = PopoverViewController.buildContentLogin(source: self)

        MainUser.sharedInstance.currentDevice = allDevices[indexPath.row]

        self.present(vc, animated: true, completion: nil)

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
        
        //Removes all stored keys from keychain.
        let sucess = KeychainWrapper.standard.removeAllKeys()
        if !sucess{
            KeychainWrapper.standard.removeObject(forKey: "user_email")
            KeychainWrapper.standard.removeObject(forKey: "user_pw")
        }
        // TODO: Implement login info reset
    }
}

