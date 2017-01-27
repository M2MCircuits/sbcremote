//
//  MyTabBarController.swift
//  Attempt2
//
//  Created by Hunter Heard on 3/31/16.
//  Copyright (c) 2016 Hunter Heard. All rights reserved.
//

import UIKit
import Foundation

class MyTabBarController: UITabBarController {

    
    //MARK Properties
    var tabCount = 0;
    var tabBarPins = [Pin]();
    
    var testValue = 5;
    
    var ipaddress = "";
    
    var devProxy = "";
    
    var session = URLSession();
    
    var weavedToken = "";
    
    var webioPiLogged = false;
    
    var raspberryDevice = NSObject();
    
    var base64LoginString = NSString();

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loading Tab Bar Controller\n");
        tabBarPins = Pin.getEmpty();
        //getIP();
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getIP() -> String
    {
        if(ipaddress != "")
        {
            return ipaddress;
        }
        
        if(ipaddress == "-1")
        {
            print("IP address still waiting...");
            return ipaddress;
        }
        
        setIP();
        return ipaddress;
    }
    
    func setIP()
    {
        if(ipaddress == "")
        {
            ipaddress = "-1";
        }
        
        let urlText = "http://ip.42.pl/raw";
        
        //these url and request objects are required for the connection method I use
        let myUrl = URL(string: urlText);
        var request = URLRequest(url:myUrl!);
        
        //set the httpmethod, and set a header value
        request.httpMethod = "GET";
        
        print("getting ip...");
     
        let task = URLSession.shared.dataTask(with: request) {
            urlData, response, error -> Void in
            
            DispatchQueue.main.async {
                
                print(String(data: urlData!, encoding: String.Encoding.utf8) ?? "[DEBUG] urlData is nil");
                print(response?.expectedContentLength ?? "[DEBUG] response is nil");
                
                do
                {
                    if urlData != nil{
                        let ip = String(data: urlData!, encoding: String.Encoding.utf8);
                        self.ipaddress = ip! as String;
                    }
                    else{
                        print("no connection");
                    }
                    
                }
                
                print("IP fetch: " + self.ipaddress);
            } // end of dispatch
        } // end of task
        
        task.resume();
    }
    
    func getPins()
    {
        let urlText = devProxy + "/*";
        let myUrl = URL(string: urlText);
        var request = URLRequest(url:myUrl!);
        
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        //set some headers
        request.httpMethod = "GET";
        
        //var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError);
        
        //start task
        let task = session.dataTask(with: request) {
            urlData, response, error -> Void in
            
            DispatchQueue.main.async {
                    
                    if(urlData == nil)
                    {
                        print("nil on fetch from Pi");
                        return;
                    }
                    
                    print("successful fetch from Pi");
                    
                    //jsonData is where the data for the response is kept
                    
                    
                    let jsonData:NSDictionary = try! JSONSerialization.jsonObject(with: urlData!, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    let GPIOdata = jsonData.value(forKey: "GPIO") as! NSDictionary;
                    //print(GPIOdata);
                    
                    for index in 0 ... 27
                    {
                        //print("setting pin ", terminator: "");
                        //print(index);

                        self.tabBarPins[index].setFromData(GPIOdata.value(forKey: String(index)) as! NSDictionary);
                        
                        //set the name to the pin number
                        self.tabBarPins[index].setName(String(index));
                        
                        
                        self.tabBarPins[index].isGPIO = true;
                        
                        //Determines by the index if it's actually a GPIO number
                        if(index < 2 || index == 14 || index == 15 || index > 27)
                        {
                            self.tabBarPins[index].isGPIO = false;
                            self.tabBarPins[index].type = 0;
                        }
                        
                        //self.printPinList();
                        
                        //print(self.tabBarPins[index].on);
                        //println(self.tabBarPins[index].type);
                        //self.testValue = self.testValue - 1;
                        //println(self.testValue);
                        
                    }
                    
                    //println(self.testValue);
                    
                    //self.printPinList();
                    
                    let optionView = self.childViewControllers[1] as! OptionTableViewController;
                    
                    optionView.pins = self.tabBarPins;
                    optionView.tableView.reloadData();
                    optionView.syncWithTable();
                    
                    //sleep(10000);
                    //self.getPins();
            } // end dispatch
        } // end task
        
        task.resume();
    }
    
    func setFunction(_ sender: UIButton, newFunction: Bool)
    {
        let nS = newFunction ? "out" : "in";
        let pinNumber = sender.tag;
        let urlText = devProxy + "/GPIO/" + String(pinNumber) + "/function/" + nS;
        let myUrl = URL(string: urlText);
        var request = URLRequest(url:myUrl!);
        
        //let loginString = NSString(format: "%@:%@", "webiopi", "raspberry");
        //let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!;
        //base64LoginString = loginData.base64EncodedStringWithOptions(nil);
        
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        //set some headers
        request.httpMethod = "POST";
        
        
        //var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError);
        
        let ps = "Posting " + nS + " to Pin " + String(pinNumber) + "function...";
        print(ps);
        
        let task = session.dataTask(with: request) {
            urlData, response, error -> Void in
            
            DispatchQueue.main.async
            {
                
                let optionView = self.childViewControllers[1] as! OptionTableViewController;
                let cell = optionView.getCellAtIndex(pinNumber);
                let res = response as! HTTPURLResponse!;
                
                if(res == nil)
                {
                    print("nil on function post from Pi");
                }
                else
                {
                    //jsonData is where the data for the response is kept
                    do
                    {
                        let jsonData:Data = try JSONSerialization.jsonObject(with: urlData!, options:[]) as! Data
                        
                        print("jsonData:");
                        print(jsonData);
                        
                    }
                    catch
                    {
                        print("jsonData not successful for pin function set");
                    }
                    
                    //Successful post!
                    if(res!.statusCode == 200)
                    {
                        //set the pin function
                        optionView.pins[pinNumber].changeFunction(newFunction);
                        
                        sender.setTitle(cell.getType(optionView.pins[pinNumber].type), for: UIControlState());
                        
                        optionView.syncWithTable();
                    }
                    else
                    {
                        print("Response status fail: " + String(res!.statusCode));
                        //cell.onState.on = !cell.onState.on;
                    }
                    
                }
                
                print("[DEBUG] urlData:");
                print(String(data: urlData!, encoding: String.Encoding.utf8) ?? "[DEBUG] urlData is nil");
                print("[DEBUG] res:");
                print(response?.expectedContentLength ?? "[DEBUG] response is nil");
                
                //Status code: 200 is inside 'res' somewhere, THAT is what will tell me if we were successful
                
                sender.isEnabled = true;
            } // end dispatch
            self.getPins();
        } // end task
        
        task.resume();
    }
    
    func setPin(_ pinNumber: Int, newState: Bool)
    {
        var nS = "0";
        
        if(newState)
        {
            nS = "1";
        }
        
        
        var urlText = devProxy + "/GPIO/";
        
        urlText += String(pinNumber) + "/value/" + nS;
        
        let myUrl = URL(string: urlText);
        var request = URLRequest(url:myUrl!);
        
        //let loginString = NSString(format: "%@:%@", "webiopi", "raspberry");
        //let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!;
        //base64LoginString = loginData.base64EncodedStringWithOptions(nil);
        
        
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        
        
        //set some headers
        request.httpMethod = "POST";
        
        
        //var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError);
        
        let ps = "Posting " + nS + " to Pin " + String(pinNumber) + "...";
        print(ps);
        
        
        
        //start task
        let task = session.dataTask(with: request) {
            urlData, response, error -> Void in
            
            DispatchQueue.main.async
                {//start dispatch
                    
                    let pinView = self.childViewControllers[2] as! PinTableViewController;
                    
                    let cell = pinView.getCellForPinNumber(pinNumber);

                    let res = response as! HTTPURLResponse!;
                    
                    if(res == nil)
                    {
                        print("nil on post from Pi");
                        cell.onState.isOn = !cell.onState.isOn;
                    }
                    else
                    {
                        //jsonData is where the data for the response is kept
                        do
                        {
                            let jsonData:Data = try JSONSerialization.jsonObject(with: urlData!, options:[]) as! Data
                            
                            print("jsonData");
                            print(jsonData);
                            
                        }
                        catch
                        {
                            print("jsonData not successful for pin set");
                        }
                        
                        
                        //Successful post!
                        if(res!.statusCode == 200)
                        {
                            self.setPinValue(pinNumber, value: newState);
                        }
                        else
                        {
                            print("Response status fail: " + String(res!.statusCode));
                            cell.onState.isOn = !cell.onState.isOn;
                        }

                    }

                    print("[DEBUG] urlData:");
                    print(String(data: urlData!, encoding: String.Encoding.utf8) ?? "[DEBUG] urlData is nil");
                    print("[DEBUG] res:");
                    print(response?.expectedContentLength ?? "[DEBUG] response is nil");
                    
                    // Status code: 200 is inside 'res' somewhere, THAT is what will tell me if we were successful
                    
                    cell.onState.isEnabled = true;
                    cell.spinner.stopAnimating();
            } // end dispatch
            self.getPins();
        } // end task
        
        task.resume();
    }

    
    func printPinList()
    {
        
        
        for p in tabBarPins{
            print(p.name, terminator: "");
            print(" ", terminator: "");
            print(p.stateName, terminator: "");
            print(" ", terminator: "");
            print(p.type, terminator: "");
            
            print("");
            
        }
        
        
        print("");
        
    }
    
    
    //sets one pin to HIGH or LOW (not on the pi, just in this program)
    func setPinValue(_ pinNumber: Int, value: Bool)
    {
        tabBarPins[pinNumber].on = value;
        let optionView = self.childViewControllers[1] as! OptionTableViewController;
        let pinView = self.childViewControllers[2] as! PinTableViewController;
        
        optionView.pins[pinNumber].on = value;
        pinView.pins[pinNumber].on = value;
        
        optionView.tableView.reloadData();
        pinView.tableView.reloadData();

        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


}
