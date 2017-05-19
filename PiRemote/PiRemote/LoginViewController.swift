//
//  LoginViewController.swift
//  PiRemote
//
//  Authors: Muhammad Martinez, Victor Aniyah
//  Copyright (c) 2017 JLL Consulting. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
class LoginViewController: UIViewController {

    @IBOutlet weak var logButton: UIButton!
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    @IBOutlet weak var paperView: UIView!
    @IBOutlet weak var passwordBox: UITextField!
    @IBOutlet weak var usernameBox: UITextField!

    // MARK: Local variables

    var isLoginSuccess = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.isNavigationBarHidden = true

        // Adding background pattern
        let patternFill = UIColor(patternImage: UIImage(named: "circuit")!)
        view.backgroundColor = patternFill

        logButton.backgroundColor = UIColor(red: 0x69/255, green: 0xbe/255, blue: 0x28/255, alpha: 1)
        logButton.setTitleColor(UIColor.white, for: .normal)
        logButton.layer.cornerRadius = logButton.bounds.size.height / 2

        // Adding event listeners
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: .UIKeyboardWillHide, object: nil)

        // Adding shadow style
        paperView!.layer.masksToBounds = false
        paperView!.layer.shadowOpacity = 0.5
        paperView!.layer.shadowOffset = CGSize(width: 0, height: 1)
        paperView!.layer.shadowRadius = 4
        paperView!.layer.shadowPath = UIBezierPath(rect: paperView!.bounds).cgPath
    }

    // MARK: Local Functions

    func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    @IBAction func onLogin(_ sender: UIButton) {
        let pass = passwordBox.text!
        let user = usernameBox.text!

        guard !pass.isEmpty else {
            SharedSnackbar.show(parent: self.view, type: .warn, message: "Please enter your password")
            return
        }

        guard !user.isEmpty else {
            SharedSnackbar.show(parent: self.view, type: .warn, message: "Please enter your username")
            return
        }

        self.loginIndicator.startAnimating()

        RemoteAPIManager().logInUser(username: user, userpw: pass, completion: { success, response, data in
            DispatchQueue.main.async {
                self.loginIndicator.stopAnimating();

                guard data != nil else{
                    self.isLoginSuccess = false
                    SharedSnackbar.show(parent: self.view, type: .error, message: "Incorrect Login")
                    return
                }

                self.isLoginSuccess = true

                // Filling out the user information with the data returned from response
                MainUser.sharedInstance.getUserInformationFromResponse(dictionary: data!)
                MainUser.sharedInstance.password = pass

                // Saving user information into NSUserDefaults since we know the informaiton is valid
                MainUser.sharedInstance.saveUser()
                
                // Supported by iOS <6.0
                self.performSegue(withIdentifier: SegueTypes.idToDevicesTable, sender: self)
            }
        })
    }

    @IBAction func onShowRemoteItInfo(_ sender: UIButton) {
        let info = "Remot3.it is used by PiRemote to find your Raspberry Pi devices."
        let alert = UIAlertController(title: "Remot3.it", message: info, preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: {action in
            alert.dismiss(animated: true, completion: nil)
        }))

        alert.addAction(UIAlertAction(title: "Visit Site", style: UIAlertActionStyle.default, handler: {action in
            UIApplication.shared.openURL(URL(string: "https://www.remot3.it/web/")! as URL)
        }))

        self.present(alert, animated: true, completion: nil)
    }
}
