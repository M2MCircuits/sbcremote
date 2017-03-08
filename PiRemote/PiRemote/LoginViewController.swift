//
//  LoginViewController.swift
//  PiRemote
//
//  Authors: Hunter Heard, Josh Binkley
//  Copyright (c) 2016 JLL Consulting. All rights reserved.
//


import UIKit

class LoginViewController: UIViewController {

    // Link to views shown in storyboard
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var displayMessage: UILabel!
    @IBOutlet weak var logButton: UIButton!
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    @IBOutlet weak var passwordBox: UITextField!
    @IBOutlet weak var usernameBox: UITextField!

    // Local variables
    var segueIdDeviceDetails = "SHOW DEVICE DETAILS"
    var segueIdDevicesTable = "SHOW DEVICES"
    var isLoginSuccess: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        isLoginSuccess = false
        if (MainUser.sharedInstance.currentDevice != nil) {
            deviceName.text = MainUser.sharedInstance.currentDevice?.deviceAlias
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Login Button
    @IBAction func handleTapLogin() {
        let passw = passwordBox.text
        let usern = usernameBox.text

        if(passw == "") {
            self.displayMessage.text = "Please enter a password.";
            return
        }

        if (self.title == "Remote Login") {
            logIntoWeaved(username: usern!, password: passw!)
        } else {
            logIntoWebIOPi(username: usern!, password: passw!)
        }
    }

    func logIntoWeaved (username: String, password: String) {
        let weavedAPIManager = RemoteAPIManager();
        weavedAPIManager.logInUser(username: username, userpw: password, callback: {
            sucess, response, data in
            DispatchQueue.main.async {
                self.loginIndicator.stopAnimating();
                self.displayMessage.text = response
                guard data != nil else{
                    return
                }

                // Fills out the user information with the data returned from response
                MainUser.sharedInstance.getUserInformationFromResponse(dictionary: data!)

                self.isLoginSuccess = true

                // Supported by iOS <6.0
                self.performSegue(withIdentifier: self.segueIdDevicesTable, sender: self)
            }
        })
    }


    func logIntoWebIOPi(username: String, password: String) {
        // TODO: Implement
        // Supported by iOS <6.0
        self.performSegue(withIdentifier: self.segueIdDeviceDetails, sender: self)
    }
/*
     // Users weaved devices, set by the HTTP request in listDevices()
     var devices: Set<NSDictionary>!

     //index of the device we will log in to
     var devIndex = 0

    //this is incorrectly labeled as WebiopiLogin
    func devWebiopiLogin(_ sen: UIButton)
    {
        //tbc = MyTabBarController, the main controller of all these view controllers
        //let cell = getListCellAtIndex(sen.tag);
        let dev = devices[sen.tag];
        let UID = (dev as AnyObject).value(forKey: "deviceaddress") as! String;
        let tbc = self.parent as! MyTabBarController;
        let ipaddress = tbc.getIP();
        let urlText = "https://api.weaved.com/v22/api/device/connect";
        //var apiKey = "WeavedDemoKey$2015"
        
        //these url and request objects are required for the connection method I use
        let myUrl = URL(string: urlText);
        var request = URLRequest(url:myUrl!);
 //       var body = NSData();
        
        //set the httpmethod, and set a header value
        request.httpMethod = "POST";
        request.setValue("application/json", forHTTPHeaderField: "Content-Type");
        request.setValue("WeavedDemoKey$2015", forHTTPHeaderField: "apikey");
        request.setValue(tbc.weavedToken, forHTTPHeaderField: "token");
        
        let params = ["deviceaddress":UID, "hostip":ipaddress, "wait":"true"] as Dictionary<String, String>;
        
        //??
        request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: [])
        
//        body.setValue(UID, forKey: "deviceaddress");
//        body.setValue(ipaddress, forKey: "hostip");
//        body.setValue("true", forKey: "wait");
        
        //request.HTTPBody = body;
        
        //cell.spinner.startAnimating();
        setListButtonEnabled(false);
        self.displayMessage.text = "Attempting to gain proxy for device...";
        
        let task = URLSession.shared.dataTask(with: request) {
            urlData, response, error in
            print("");
            DispatchQueue.main.async {
                
                self.displayMessage.text = "Connected";
                
                //stop the spinner, unlock the buttons
                //cell.spinner.stopAnimating();
                self.setListButtonEnabled(true);
                
                if(urlData != nil)
                {
                    //println("urlData != nil");
                    //jsonData is where the data for the response is kept
                    let jsonData = try! JSONSerialization.jsonObject(with: urlData!, options:JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                    
                    let status = jsonData["status"] as! String;
                    
                    if(status == "false") {
                        print("status: false");
                        print("reason: " + (jsonData["reason"] as! String));
                        self.displayMessage.text = "WebIOPi device authentification failed";
                    } else {
                        //  set the variable saying we are logged in to the pi (this should be on TBC)
                        tbc.webioPiLogged = true;
                        //set ONLY the current device to logged in
                        var nCells = self.devices.count;
                        if (nCells == 0) {
                            return;
                        }
                        
                        nCells = nCells - 1;
                        
                  /*      for index in 0...nCells {
                            let disablelogcell = self.getListCellAtIndex(index);
                            disablelogcell.setLog(false)
                        }
                        cell.setLog(true);
                */
                        self.devIndex = sen.tag;
                    
                        let proxy = jsonData["connection"]?.value(forKey: "proxy") as! String;
                    
                        print(proxy);
                        tbc.devProxy = proxy;
                        self.devIndex = sen.tag;
                        self.devFetchTest();
                        
                        //  set this device's login button to 'logout'
                        //cell.devLogButton.setTitle("Logged in", forState: UIControlState.Normal);
                        //cell.setName("(Logged in) + " + cell.aliasLabel.text!);
                        //  set all the variables in TBC needed in order to talk to the Pi
                        //      pi address, token, whatever
                    }
                }
            } // end dispatch
        } // end task
        task.resume();
    }
*/

    //because persistant text is annoying
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}
