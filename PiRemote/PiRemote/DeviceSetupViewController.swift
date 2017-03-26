//
//  DeviceSetupViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 2/26/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

class DeviceSetupViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    

    override func viewDidLoad() {
        super.viewDidLoad();

        // Additional navigation setup
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(DeviceSetupViewController.onCancel))
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(DeviceSetupViewController.onSaveChanges))

        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.title = "Device Setup"
    }

    // TODO: Fix code smell, duplicate code from DevicesTableViewController.swift
    @IBAction func onSetWebLogin(_ sender: Any) {
        // Get a reference to the view controller for the popover
        let content = storyboard?.instantiateViewController(withIdentifier: "WEB_DIALOG") as! WebLoginViewController
        content.modalPresentationStyle = .popover
        content.onLoginSuccess = {() -> () in
            // self.performSegue(withIdentifier: SegueTypes.idToDeviceDetails, sender: nil)
        }

        // Container for the content
         let popover = content.popoverPresentationController
         popover?.delegate = self
         popover?.permittedArrowDirections = .up
         popover?.sourceView = self.view
         // TODO: Center popover based on device
         popover?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 360, height: 420)


        self.present(content, animated: true, completion: nil)
    }

    func onSaveChanges(sender: UIButton!) {
        // TODO: Implement saving the layout
        self.dismiss(animated: true, completion: nil)
    }

    func onCancel(sender: UIButton!) {
        self.dismiss(animated: true, completion: nil)
    }

    // Prevents popover from changing style based on the iOS device
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
