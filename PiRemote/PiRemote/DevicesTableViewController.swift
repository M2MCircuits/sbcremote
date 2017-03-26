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
        cell.deviceName.text = allDevices[indexPath.row].deviceAlias
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
        let content = storyboard?.instantiateViewController(withIdentifier: "WEB_DIALOG") as! WebLoginViewController
        content.modalPresentationStyle = .popover
        content.onLoginSuccess = {() -> () in
            self.performSegue(withIdentifier: SegueTypes.idToDeviceDetails, sender: nil)
        }

        // Container for the content
        let popover = content.popoverPresentationController
        popover?.delegate = self
        popover?.permittedArrowDirections = .up
        popover?.sourceView = self.view
        // TODO: Center popover based on device
        popover?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 360, height: 420)

        self.present(content, animated: true, completion: nil)
        
        return indexPath
    }

    // Prevents popover from changing style based on the iOS device
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    // Local Functions
    func logout(sender: UIButton!) {
        self.dismiss(animated: true, completion: nil)
        // TODO: Implement login info reset
    }
}

