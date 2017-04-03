//
//  WebLoginViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 3/25/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

class WebLoginViewController: UIViewController,
    UIPopoverPresentationControllerDelegate,
    UITextInputDelegate {

    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var passwordBox: UITextField!
    @IBOutlet weak var portBox: UITextField!
    @IBOutlet weak var saveLoginSwitch: UISwitch!
    @IBOutlet weak var usernameBox: UITextField!

    // Local Variables
    var onLoginSuccess: (()->Void)! // callback

    required init?(coder aDecoder: NSCoder) {
        // Setup properties (if any)

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup loading the view, typically from a nib
        // TODO: Debug why errorView is not showing/hiding
        //self.errorView!.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of resources that can be recreated.
    }

    // Local Functions
    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func onAction(_ sender: Any) {
        handleLogin()
        self.dismiss(animated: true, completion: nil)
        // TODO: Implement case for DeviceSetup
    }

    func handleLogin() {
        // Validate login by getting the device's state
        let deviceIP = MainUser.sharedInstance.currentDevice?.apiData["deviceLastIP"]
        let username = (usernameBox.text?.isEmpty)! ? usernameBox.placeholder : usernameBox.text
        let password = (passwordBox.text?.isEmpty)! ? passwordBox.placeholder : passwordBox.text
        let port = (portBox.text?.isEmpty)! ? portBox.placeholder : portBox.text

        let webApiManager = WebAPIManager(ipAddress: deviceIP, port: port, username: username, password: password)
        webApiManager.getFullGPIOState(callback: { data in
            guard data != nil else {
                // Login Failed
                let newMessage = self.errorView.subviews[1] as! UILabel
                newMessage.text = "Invalid login"
                self.errorView!.isHidden = false
                return
            }

            // Login Succeeded
            MainUser.sharedInstance.currentDevice!.stateJson = data!["GPIO"] as! [String: [String:AnyObject]]

            NotificationCenter.default.post(name: NotificationNames.loginSuccess, object: nil)
        });
    }

    // Prevents popover from changing style based on the iOS device
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    // UITextInputDelegate functions
    func selectionWillChange(_ textInput: UITextInput?) { }
    func selectionDidChange(_ textInput: UITextInput?) { }
    func textWillChange(_ textInput: UITextInput?) { }

    func textDidChange(_ textInput: UITextInput?) {
        self.errorView!.isHidden = true
    }

}
