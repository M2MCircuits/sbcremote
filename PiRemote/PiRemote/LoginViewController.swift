//
//  LoginViewController.swift
//  PiRemote
//
//  Authors: Hunter Heard, Josh Binkley
//  Copyright (c) 2016 JLL Consulting. All rights reserved.
//


import UIKit

class LoginViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //A table view of the devices found on the current Weaved login
    //@IBOutlet var devTable: UITableView!
    
    //these are "links" to the username and password text boxes
    //they should've been called "usernamebox" or something like that, but too late
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    //these are "links" to the Login button and the activity indicator next to the Login button
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    @IBOutlet weak var logButton: UIButton!
    
    //Indicator for fetching the list of weaved devices
    //@IBOutlet weak var listFetchIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var ErrorLabel: UILabel!
    @IBOutlet weak var displayMessage: UILabel!

    //an array of weaved devices, set by the HTTP request in listDevices()
    var devices: Set<NSDictionary>!

    //index of the device we will log in to
    var devIndex = 0

    // When the login button is pressed, this method is called.
    @IBAction func logPress(_ sender: UIButton) {
        
        sender.isEnabled = false;
        
        
        self.view.endEditing(true);

        
        let usern = username.text;

        let passw = password.text;
        
        if(passw == "")
        {
            self.displayMessage.text = "Please enter a password.";
            sender.isEnabled = true;
            return;
        }
        
        logInToWeaved(usern!,passw: passw!);
        
        
    }
    
    // when the "login" button next to a Weaved device is pressed
    @IBAction func devLoginButtonPress(_ sender: UIButton) {
      
        self.view.endEditing(true);
        /*
        let cell = getListCellAtIndex(sender.tag);
        
        if(cell.passwordLabel.text == "")
        {
            // self.displayMessage.text = "Please enter a password.";
            return;
        }
        */
        
        //devWebiopiLogin(sender);
        
        
    }
    
    //this is a test label I use to print information on the login attempt
    //@IBOutlet weak var logSuccessLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //set the table to use the Login screen view controller as a datasource and delegate
        //that way I can control it from this view controller
        //self.devTable.dataSource = self;
        //self.devTable.delegate = self;
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func logInToWeaved(_ usern: String, passw: String)
    {
        loginIndicator.startAnimating();

        let tbc = self.parent as! MyTabBarController;
        tbc.setIP();
        let weavedAPIManager = WeavedAPIManager();

        weavedAPIManager.logInUser(username: usern, userpw: passw, callback: {
            sucess, response, data in
            DispatchQueue.main.async {
                self.loginIndicator.stopAnimating();
                self.displayMessage.text = response
                guard data != nil else{
                    return
                }
                
                let data = data!
                tbc.weavedToken = data["token"] as! String
                self.logButton.setTitle("Logged In", for: UIControlState())
                self.password.text = ""
                self.reloadInputViews();
                self.listDevices();
                //Fills out the user information with the data returned from response
                MainUser.sharedInstance.getUserInformationFromResponse(dictionary: data)
            }
        })
    }
    
    
    //this method requests a list of devices from Weaved
    //it receives among other things an array of devices, which includes their names, addresses, stuff like that
    //It puts that array into the variable called 'devices', and sets devCount to the number of devices
    //Then it tells the table to reload itself, and the table uses 'devices' and devCount to do so
    //So the actual listing is done by the tableview methods
    func listDevices()
    {
        let tbc = self.parent as! MyTabBarController;
        let weavedAPIManager = WeavedAPIManager();

        weavedAPIManager.listDevices(token: tbc.weavedToken, callback: {
            data in
            if (data != nil) {
                let deviceManager = WeavedDeviceManager()
                let (sshDevices, nonsshDevices) = deviceManager.createDevicesFromAPIResponse(data: data!)
                self.displayMessage.text = "\(sshDevices.count + nonsshDevices.count) Devices Found (\(sshDevices.count) SSH)";
            } else {
                self.displayMessage.text = "Error: failed to get device list";
            }
        })
    }
    
    //The number of cells in the device table gets set to the number of devices
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4;//devices.count;
    }
   
    //THIS is the method called when the table needs to define a cell at a certain index
    //it gets called when a cell is scrolled off the screen I think
    //it also gets called for every cell when the table is reloaded I think
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ListTableViewCell";
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ListTableViewCell
        
       /* cell.setName("nothing");//devices[indexPath.row]["devicealias"] as! String);
        cell.tag = indexPath.row;
        cell.devLogButton.tag = indexPath.row;
        */
        return cell
    }
    
    //when a device is selected from the table after logging in to Weaved,
    //we should call this function, which will attempt to contact the device.
    //if successful, it will make some sort of signal on the login screen
    //if successful, it will also perhaps make some sort of segue to the control screen
    //it will set some variables that can be accessed from any of the view controllers
    //  -variables declaring if the iPhone is logged into Weaved
    //  -if we are logged into a Pi
    //  -if we are making successful connections to the Pi?
    //  -information required to access the Pi, and control the pins
    //if unsuccessful, it will signal the login screen somehow with a fail message
   /* func getListCellAtIndex(_ index: Int) -> ListTableViewCell
    {
        let path = IndexPath(row: index, section: 0);
        let cell = devTable.cellForRow(at: path) as! ListTableViewCell;
        return cell;
    }
    */
    //lock or unlock all of the login buttons in the device table
    func setListButtonEnabled(_ enable: Bool)
    {
        var nCells = devices.count;
        
        if (nCells == 0) {
            return;
        }
       /*
        nCells = nCells - 1;
        for index in 0...nCells {
            let cell = getListCellAtIndex(index);
            cell.devLogButton.isEnabled = enable;
        }
        */
        return;
    }
    
/*
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
    func devFetchTest()
    {
        let tbc = self.parent as! MyTabBarController;
        tbc.session = URLSession.shared;

        let urlText = tbc.devProxy + "/*";
        //let cell = getListCellAtIndex(devIndex);
        let myUrl = URL(string: urlText);
        var request = URLRequest(url:myUrl!);
        //let usrn = cell.userNameLabel.text!;
        //let pass = cell.passwordLabel.text!;
        
        //cell.passwordLabel.text! = "";
        
        //print("Username: " + usrn + "\nPassword: " + pass);
        
        //let loginString = NSString(format: "%@:%@", usrn, pass);
        //let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!;
    /*    tbc.base64LoginString = loginData.base64EncodedString(options: []) as NSString;
        
        request.setValue("Basic \(tbc.base64LoginString)", forHTTPHeaderField: "Authorization")

        //set some headers
        request.httpMethod = "GET";
        //var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError);
        
        //cell.spinner.startAnimating();
        
        let task = tbc.session.dataTask(with: request) {
            urlData, response, error in
            
            DispatchQueue.main.async {
                
                //cell.spinner.stopAnimating();
                
                if(urlData == nil) {
                    print("nil on fetch from Pi");
                    return;
                }
                
                let res = response as! HTTPURLResponse;
                print(res);
                
                var jsonData: [String: AnyObject];
                
                //jsonData is where the data for the response is kept
                do {
                    jsonData = try JSONSerialization.jsonObject(with: urlData!, options:JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                } catch {
                    print("jsonData from devFetchTest() failure");
                    return;
                }
                
                print("successful fetch from Pi");

                let pinarray = jsonData["GPIO"] as! [String: AnyObject];
                
                print(pinarray["0"] ?? "No value for pin 0");
                
                tbc.getPins();
                
                //println(jsonData);
                //println(urlData);
                //println(res);
                
            } // end dispatch
        } // end task
        task.resume();*/
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //display a disappearing message to user
    func displayMessage(_ msg:String) {
    
        self.ErrorLabel.text = msg;
        self.delay(3.0) {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.ErrorLabel.alpha = 0.0
            },
                completion:{ (finished: Bool) -> Void in
                    self.ErrorLabel.text = "";
                    self.ErrorLabel.alpha = 1.0;
                }
            )
        }
    }
    //because persistant text is annoying
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}
