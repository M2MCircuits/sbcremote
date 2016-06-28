//
//  LoginViewController.swift
//  PiRemote
//
//  Authors: Hunter Heard, Josh Binkley
//  Copyright (c) 2016 JLL Consulting. All rights reserved.
//


import UIKit

class LoginViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    //let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration());
    
    //var task: NSURLSessionDataTask?

    //not used
    @IBOutlet weak var DeviceTable: UITableView!
    
    //A table view of the devices found on the current Weaved login
    @IBOutlet var devTable: UITableView!
    
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
    
    
    //an array of weaved devices, set by the HTTP request in listDevices()
    var devices = NSArray();
    
    //index of the device we will log in to
    var devIndex = 0;

    
    
    //When the login button is pressed, this method is called.
    @IBAction func logPress(sender: UIButton) {
        
        sender.enabled = false;
        
        
        self.view.endEditing(true);

        
        let usern = username.text;
        
        let passw = password.text;
        
        if(passw == "")
        {
            self.displayMessage("Please enter a password.");
            sender.enabled = true;
            return;
        }
        
        logInToWeaved(usern!,passw: passw!);
        
        
    }
    
    //when the "login" button next to a Weaved device is pressed
    @IBAction func devLoginButtonPress(sender: UIButton) {
      
        self.view.endEditing(true);
        
        let cell = getListCellAtIndex(sender.tag);
        
        if(cell.passwordLabel.text == "")
        {
            self.displayMessage("Please enter a password.");
            return;
        }
        
        
        devWebiopiLogin(sender);
        
        
    }
    
    //this is a test label I use to print information on the login attempt
    //@IBOutlet weak var logSuccessLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //set the table to use the Login screen view controller as a datasource and delegate
        //that way I can control it from this view controller
        self.devTable.dataSource = self;
        self.devTable.delegate = self;
        
        
        // Do any additional setup after loading the view.
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func logInToWeaved(usern: String, passw: String)
    {
        let tbc = self.parentViewController as! MyTabBarController;
        
        tbc.setIP();
        
        let session = NSURLSession.sharedSession()

        
        var urlText = "https://api.weaved.com/v22/api/user/login/";
        
        urlText += usern + "/";
        urlText += passw;
        
        //these url and request objects are required for the connection method I use
        let myUrl = NSURL(string: urlText);
        let request = NSMutableURLRequest(URL:myUrl!);
        
        //set the httpmethod, and set a header value
        request.HTTPMethod = "GET";
        request.setValue("WeavedDemoKey$2015", forHTTPHeaderField: "apikey");
        
        //var urlData: NSData?
        
        
        loginIndicator.startAnimating();
        
        self.displayMessage("Logging in to Weaved...");
        //start task definition
        let task = session.dataTaskWithRequest(request, completionHandler:{
            urlData, response, error -> Void in
            // this code runs asynchronously...
            // ... i.e. later, after the request has completed (or failed)
            
            
            //odd bug
            //with this dispatch code and self.reloadInputViews(); the indicator
            //will stop spinning as soon as the stuff is printed.
            //but with the extra self.loginIndicator.stopAnimating() outside of the dispatch code,
            //the spinner stops animating, but doesn't disappear, as it is set to.....
//            dispatch_async(dispatch_get_main_queue()) {
//                self.loginIndicator.stopAnimating();
//            }
//            
//            self.loginIndicator.stopAnimating();
//            
//            self.reloadInputViews();

            print("reached dispatch");
            dispatch_async(dispatch_get_main_queue()) {
                self.loginIndicator.stopAnimating();
                self.logButton.enabled = true;
                
                if let error = error{
                    print(error.localizedDescription, terminator: "")
                }
                else {print("no error");}
                
                if(urlData != nil)
                {
                    print("urlData != nil");
                    //ErrorLabel.text = "Success";
                    
                    //jsonData is where the data for the response is kept
                    let jsonData:NSDictionary = try! NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    let status = jsonData.valueForKey("status") as! String;
                    
                    if(status == "true")
                    {
                        self.logButton.setTitle("Logged In", forState: UIControlState.Normal);
                        
                        //we set the Token in the main TabBarController
                        tbc.weavedToken = jsonData.valueForKey("token") as! String;
                        print("token: " + tbc.weavedToken);
                        
                        
                        //set the label on the log screen
                        //self.displayMessage(tbc.weavedToken);
                        
                        //clear the password box
                        self.password.text = "";
                        
                        
                        
                        
                        //self.reloadInputViews();
                        
                        self.listDevices();
                        
                    }
                    else
                    {
                        self.displayMessage(jsonData.valueForKey("reason") as! String);
                        
                        
                    }

                }
                else
                {
                    self.displayMessage("Error: no internet connection");
                }
                
                
                
                
                return;
            }
            
            

            
        })
        
        task.resume();
        
        
        
        //THIS is the connection command
        //var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError);

        
        
        
        

//
//        let task = NSURLSession.sharedSession().dataTaskWithRequest(request)
//        {
//                
//            data, response, error in
//            
//            
//            
//        }
//        
//        
//        task.resume();
        
        
        
    }
    
    
    //this method requests a list of devices from Weaved
    //it receives among other things an array of devices, which includes their names, addresses, stuff like that
    //It puts that array into the variable called 'devices', and sets devCount to the number of devices
    //Then it tells the table to reload itself, and the table uses 'devices' and devCount to do so
    //So the actual listing is done by the tableview methods
    func listDevices()
    {
        let tbc = self.parentViewController as! MyTabBarController;
        
        
        let urlText = "https://api.weaved.com/v22/api/device/list/all";
        
        let session = NSURLSession.sharedSession();

        
        
        let myUrl = NSURL(string: urlText);
        let request = NSMutableURLRequest(URL:myUrl!);
        
        //set some headers
        request.HTTPMethod = "GET";
        request.setValue("WeavedDemoKey$2015", forHTTPHeaderField: "apikey");
        request.setValue("application/json", forHTTPHeaderField: "Content-Type");
        request.setValue(tbc.weavedToken, forHTTPHeaderField: "token");
        
        
        //var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError);
        
        print("\nsending list request...");
        //listFetchIndicator.startAnimating();
        
        //start task
        let listtask = session.dataTaskWithRequest(request, completionHandler:{
            urlData, response, error -> Void in
            
            dispatch_async(dispatch_get_main_queue())
            {//start dispatch
                
                //self.listFetchIndicator.stopAnimating();
                
                if(urlData != nil)
                {
                    //ErrorLabel.text = "Success";
                    
                    print("received list");
                    
                    let jsonData:NSMutableDictionary = try! NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers) as! NSMutableDictionary
                    
                    
                    
                    //devices is declared at the beginning of this class
                    //it's an array of these devices
                    self.devices = jsonData.valueForKey("devices") as! NSArray;
                    
                    //REMOVE SSH ENTRIES
                    let temparray = self.devices as! NSMutableArray;
                    var sshindexarr = [Int]();
                    var i = 0;
                    for item in temparray{
                        let alias: String? = item.objectForKey("devicealias") as? String
                        if alias!.rangeOfString("_ssh") != nil{
                            
                            //REMOVE SSH DEVICE
                            sshindexarr.append(i);
                        }
                        i=i+1;
                    }
                    
                    var inx = sshindexarr.count - 1;
                    repeat {
                        temparray.removeObjectAtIndex(sshindexarr[inx]);
                        inx = inx - 1;
                    } while (inx >= 0)
                    
                    self.devices = temparray;
                    
                    //GET DEVICE ADDRESSES
                    for device in temparray{
                        print("DEVICE ADDRESSSS",(device.objectForKey("deviceaddress") as! String));
                    }
                    
                    //the actual listing of the devices is done by the tableView functions in this class
                    //this just sets up devices and devCount, and tells the table to reload
                    
                    self.devTable.reloadData();
                    
                    
                    
                    //DeviceTable.insertRowsAtIndexPaths(0, withRowAnimation: UITableViewRowAnimation.Automatic);
                    
                    
                    
                }
                else
                {
                    self.displayMessage("Failed to get device list");
                }
                
            }//end dispatch
        })//end task
        listtask.resume();
        
        
        
        
        
        
    }
    
    //The number of cells in the device table gets set to the number of devices
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return devices.count;
    }
   
    //THIS is the method called when the table needs to define a cell at a certain index
    //it gets called when a cell is scrolled off the screen I think
    //it also gets called for every cell when the table is reloaded I think
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ListTableViewCell";
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ListTableViewCell
        
        cell.setName(devices[indexPath.row].valueForKey("devicealias") as! String);
        
        cell.tag = indexPath.row;
        
        cell.devLogButton.tag = indexPath.row;
        
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
    func getListCellAtIndex(index: Int) -> ListTableViewCell
    {
        let path = NSIndexPath(forRow: index, inSection: 0);
        
        let cell = devTable.cellForRowAtIndexPath(path) as! ListTableViewCell;
        
        return cell;
    }
    
    //lock or unlock all of the login buttons in the device table
    func setListButtonEnabled(enable: Bool)
    {
        var nCells = devices.count;
        
        if (nCells == 0)
        {
            return;
        }
        
        nCells = nCells - 1;
        
        for index in 0...nCells
        {
            let cell = getListCellAtIndex(index);
            
            cell.devLogButton.enabled = enable;
        }
        
        return;
        
    }
    
    
    //this is incorrectly labeled as WebiopiLogin
    func devWebiopiLogin(sen: UIButton)
    {
        //tbc = MyTabBarController, the main controller of all these view controllers
        let tbc = self.parentViewController as! MyTabBarController;
        
        let dev = devices[sen.tag];
        let UID = dev.valueForKey("deviceaddress") as! String;
        
        let ipaddress = tbc.getIP();
        
        let cell = getListCellAtIndex(sen.tag);
        
        let session = NSURLSession.sharedSession();
        
        
        let urlText = "https://api.weaved.com/v22/api/device/connect";
        
        //var apiKey = "WeavedDemoKey$2015"
        
        
        
        //these url and request objects are required for the connection method I use
        let myUrl = NSURL(string: urlText);
        let request = NSMutableURLRequest(URL:myUrl!);
 //       var body = NSData();
        
        //set the httpmethod, and set a header value
        request.HTTPMethod = "POST";
        request.setValue("application/json", forHTTPHeaderField: "Content-Type");
        request.setValue("WeavedDemoKey$2015", forHTTPHeaderField: "apikey");
        request.setValue(tbc.weavedToken, forHTTPHeaderField: "token");
        
        let params = ["deviceaddress":UID, "hostip":ipaddress, "wait":"true"] as Dictionary<String, String>;
        
        //??
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(params, options: [])

        
//        body.setValue(UID, forKey: "deviceaddress");
//        body.setValue(ipaddress, forKey: "hostip");
//        body.setValue("true", forKey: "wait");
        
        //request.HTTPBody = body;
        
        cell.spinner.startAnimating();
        setListButtonEnabled(false);
        self.displayMessage("Attempting to gain proxy for device...");
        
        let weblogtask = session.dataTaskWithRequest(request, completionHandler:{
            urlData, response, error -> Void in
            
            print("");
            
            dispatch_async(dispatch_get_main_queue())
            {
                
                self.displayMessage("Connected");
                
                //stop the spinner, unlock the buttons
                cell.spinner.stopAnimating();
                self.setListButtonEnabled(true);
                
                
                if(urlData != nil)
                {
                    //println("urlData != nil");
                    
                    
                    //jsonData is where the data for the response is kept
                    let jsonData:NSDictionary = try! NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    let status = jsonData.valueForKey("status") as! String;
                    
                    if(status == "false")
                    {
                        print("status: false");
                        
                        print("reason: " + (jsonData.valueForKey("reason") as! String));
                        
                        self.displayMessage("WebIOPi device authentification failed");
                        
                        
                    }
                    else
                    {
                        //  set the variable saying we are logged in to the pi (this should be on TBC)
                        tbc.webioPiLogged = true;
                        
                        
                        //set ONLY the current device to logged in
                        var nCells = self.devices.count;
                        if (nCells == 0)
                        {
                            return;
                        }
                        
                        nCells = nCells - 1;
                        
                        for index in 0...nCells
                        {
                            let disablelogcell = self.getListCellAtIndex(index);
                            
                            disablelogcell.setLog(false)
                        }
                        cell.setLog(true);
                        
                        
                        self.devIndex = sen.tag;
                        
                        let proxy = (jsonData.valueForKey("connection") as! NSObject).valueForKey("proxy") as! String;
                        
                        
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
                
                
                
            }//end dispatch

            
            
        })//end weblogtask
        weblogtask.resume();
        

        
        
    }
    
    
    
    func devFetchTest()
    {
        let tbc = self.parentViewController as! MyTabBarController;
        
        tbc.session = NSURLSession.sharedSession();
        
        
        let urlText = tbc.devProxy + "/*";
        
        let cell = getListCellAtIndex(devIndex);
        
        let myUrl = NSURL(string: urlText);
        let request = NSMutableURLRequest(URL:myUrl!);
        
        
        let usrn = cell.userNameLabel.text!;
        let pass = cell.passwordLabel.text!;
        
        cell.passwordLabel.text! = "";
        
        print("Username: " + usrn + "\nPassword: " + pass);
        
        
        let loginString = NSString(format: "%@:%@", usrn, pass);
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!;
        tbc.base64LoginString = loginData.base64EncodedStringWithOptions([]);
        
        
        request.setValue("Basic \(tbc.base64LoginString)", forHTTPHeaderField: "Authorization")

        
        
        //set some headers
        request.HTTPMethod = "GET";
        
        
        
        //var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError);
        
        cell.spinner.startAnimating();
        
        //start task
        let task = tbc.session.dataTaskWithRequest(request, completionHandler:{
            urlData, response, error -> Void in
            
            dispatch_async(dispatch_get_main_queue())
            {//start dispatch
                
                cell.spinner.stopAnimating();
                
                if(urlData == nil)
                {
                    print("nil on fetch from Pi");
                    return;
                }
                
                
                let res = response as! NSHTTPURLResponse;
                print(res);
                
                var jsonData = NSDictionary();
                
                //jsonData is where the data for the response is kept
                do
                {
                    jsonData = try NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers) as! NSDictionary
                }
                catch
                {
                    print("jsonData from devFetchTest() failure");
                    return;
                }
                
                print("successful fetch from Pi");

                
                
                let pinarray = jsonData.valueForKey("GPIO") as! NSDictionary;
                
                print(pinarray.valueForKey("0"));
                
                tbc.getPins();
                
                //println(jsonData);
                
                //println(urlData);
                //println(res);
                
            }//end dispatch
            
            
            
        })//end task
        
        task.resume();
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
    func displayMessage(msg:String){
    
        self.ErrorLabel.text = msg;
        self.delay(3.0) {
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
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
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}
