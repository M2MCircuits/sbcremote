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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Additional navigation setup
        let logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DevicesTableViewController.logout))

        self.navigationItem.leftBarButtonItem = logoutButton

        // Pull latest devices from Remote.it account
        let remoteToken = MainUser.sharedInstance.token
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
                OperationQueue.main.addOperation {
                    self.devicesTableView.reloadData()
                }
        })

        dialogMessage = "Enter login for this devices WebIOPi server."
    }

    @IBAction func unwindToTable(segue: UIStoryboardSegue) {

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
        cell.deviceName.text = allDevices[indexPath.row].apiData["deviceAlias"]
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sshDevices.count + nonSshDevices.count;
    }

    // UITableViewDelegate Functions
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let allDevices = sshDevices + nonSshDevices
        MainUser.sharedInstance.currentDevice = allDevices[indexPath.row]

        // Get a reference to the view controller for the popover
        let popoverContent = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WEBIOPI_DIALOG")

        // Set the presentation style
        var nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        var popover = nav.popoverPresentationController!
        popoverContent.preferredContentSize = CGSize(width: 500, height: 600)
        popover.delegate = self
        popover.sourceView = self.view
        popover.sourceRect = CGRect(x: 100, y: 100, width: 300, height: 300)

        self.present(nav, animated: true, completion: nil)
        /*

         popoverVC.popoverPresentationController?.sourceRect = CGRect(x: 10, y: 10, width: 335, height: 335)
         popoverVC.modalPresentationStyle = UIModalPresentationStyle.popover
         popoverVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
         popoverVC.popoverPresentationController?.delegate = self

         // present the popover
         self.present(popoverVC, animated: true, completion: nil)
         
         */
        // Supported by iOS <6.0
//        self.performSegue(withIdentifier: SegueTypes.idToWebLogin, sender: self)
        
        return indexPath
    }

    // Local Functions
    func logout(sender: UIButton!) {
        _ = self.navigationController?.popViewController(animated: true)
        // TODO: Implement login info reset
    }
}

