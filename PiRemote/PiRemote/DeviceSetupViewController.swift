//
//  DeviceSetupViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 2/26/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

class DeviceSetupViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad();

        // Additional navigation setup
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(DeviceSetupViewController.onFinishSetup))

        self.navigationItem.rightBarButtonItem = doneButton
    }

    func onFinishSetup(sender: UIButton!) {
        // TODO: Implement saving the layout
        _ = self.navigationController?.popViewController(animated: true)
    }
}
