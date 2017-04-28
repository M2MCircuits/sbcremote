//
//  WebLoginViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 3/25/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

class WebLoginViewController: UIViewController,UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var passwordBox: UITextField!
    @IBOutlet weak var rememberMeLabel: UILabel!
    @IBOutlet weak var saveLoginSwitch: UISwitch!
    @IBOutlet weak var usernameBox: UITextField!

    // MARK: Local Variables

    var domain: String!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.activityIndicator.isHidden = true
    }

    // MARK: UIPopoverPresentationControllerDelegate

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Prevents popover from changing style based on the iOS device
        return .none
    }

    // MARK: Local Functions

    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }

    @IBAction func onLogin(_ sender: UIBarButtonItem) {
        let save = saveLoginSwitch.isOn
        let pass = passwordBox.text!.isEmpty ? passwordBox.placeholder : passwordBox.text!
        let user = usernameBox.text!.isEmpty ? usernameBox.placeholder : usernameBox.text!

        if usernameBox.text!.isEmpty {
            SharedSnackbar.show(parent: self.view, type: .info, message: "Using default username")
        } else if passwordBox.text!.isEmpty {
            SharedSnackbar.show(parent: self.view, type: .info, message: "Using default password")
        }

        // Preventing consecutives calls to login
        guard !activityIndicator.isAnimating else { return }

        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.dismiss(animated: false) {
            NotificationCenter.default.post(name: Notification.Name.login, object: nil, userInfo: ["username": user!, "password": pass!, "save": save])
        }
    }
}
