//
//  MyTabBarController.swift
//  PiRemote
//
//  Authors: Hunter Heard, Josh Binkley
//  Copyright (c) 2016 JLL Consulting. All rights reserved.
//

import UIKit
import Foundation

// DEPRECATED: No connection to storyboard.
// TODO: Evaluate code to see what can be learned/reused
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
        if(ipaddress != "") {
            return ipaddress;
        }
        
        if(ipaddress == "-1") {
            print("IP address still waiting...");
            return ipaddress;
        }

        setIP();
        return ipaddress;
    }
    
    func setIP()
    {
        if(ipaddress == "") {
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
                print(urlData!);
                do {
                    if urlData != nil {
                        self.ipaddress = String(data: urlData!, encoding: String.Encoding.utf8)!;
                    } else {
                        print("no connection");
                    }
                }
                print("IP fetch: " + self.ipaddress);
            } // end dispatch
        } // end task
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
        
        let task = URLSession.shared.dataTask(with: request) {
            urlData, response, error -> Void in

            DispatchQueue.main.async {
                    if(urlData == nil) {
                        print("nil on fetch from Pi");
                        return;
                    }
                    
                    print("successful fetch from Pi");
                
                    //jsonData is where the data for the response is kept
                    let jsonData = try! JSONSerialization.jsonObject(with: urlData!, options:JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                
                    let GPIOdata = jsonData["GPIO"] as! [String: AnyObject];
                    //print(GPIOdata);
                    
                    for index in 0 ... 27 {
                        //print("setting pin ", terminator: "");
                        //print(index);

                        self.tabBarPins[index].setFromData(GPIOdata[String(index)] as! NSDictionary);
                        
                        //set the name to the pin number
                        self.tabBarPins[index].setName(String(index));
                        self.tabBarPins[index].isGPIO = true;
                        
                        //Determines by the index if it's actually a GPIO number
                        if(index < 2 || index == 14 || index == 15 || index > 27) {
                            self.tabBarPins[index].isGPIO = false;
                            self.tabBarPins[index].type = 0;
                        }
                        
                        //self.printPinList();
                        
                        //print(self.tabBarPins[index].on);
                        //println(self.tabBarPins[index].type);
                        //self.testValue = self.testValue - 1;
                        //println(self.testValue);
                        
                    }
                    

                    //sleep(10000);
                    //self.getPins();
            } // end dispatch
        } // end task

        task.resume();
    }
    /*
    func setFunction(_ sender: UIButton, newFunction: Bool)
    {
        let nS = newFunction ? "out" : "in";
        let pinNumber = sender.tag;
        var urlText = devProxy + "/GPIO/";
        
        urlText += String(pinNumber) + "/function/" + nS;
        
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
        
        let task = URLSession.shared.dataTask(with: request) {
            urlData, response, error in
            
            DispatchQueue.main.async {
                let optionView = OptionTableViewController()
                let cell = optionView.getCellAtIndex(pinNumber);
                let res = response as! HTTPURLResponse!;
                
                if(res == nil) {
                    print("nil on function post from Pi");
                } else {
                    //jsonData is where the data for the response is kept
                    do {
                        let jsonData:Data = try JSONSerialization.jsonObject(with: urlData!, options:[]) as! Data
                        print("jsonData: \(jsonData)");
                    } catch {
                        print("jsonData not successful for pin function set");
                    }
                    
                    
                    //Successful post!
                    if(res!.statusCode == 200) {
                        //set the pin function
                        optionView.pins[pinNumber].changeFunction(newFunction);
                        sender.setTitle(cell.getType(optionView.pins[pinNumber].type), for: UIControlState());
                        optionView.syncWithTable();
                    } else {
                        print("Response status fail: " + String(res!.statusCode));
                        //cell.onState.on = !cell.onState.on;
                    }
                }

                print("urlData: \(urlData)");
                print("res: \(res)");
                
                //Status code: 200 is inside 'res' somewhere, THAT is what will tell me if we were successful
                
                sender.isEnabled = true;
            } // end dispatch
            self.getPins();
        } // end task
        
        task.resume();
    }

    func setPin(_ pinNumber: Int, newState: Bool)
    {
        let nS = newState ? "1" : "0";
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
        
        let task = URLSession.shared.dataTask(with: request) {
            urlData, response, error in
            
            DispatchQueue.main.async {
                    
                    let pinView = PinTableViewController()
                    //let cell = pinView.getCellForPinNumber(pinNumber);
                    let res = response as! HTTPURLResponse!;
                    
                    if(res == nil) {
                        print("nil on post from Pi");
                        cell.onState.isOn = !cell.onState.isOn;
                    } else {
                        //jsonData is where the data for the response is kept
                        do {
                            let jsonData:Data = try JSONSerialization.jsonObject(with: urlData!, options:[]) as! Data
                            
                            print("jsonData");
                            print(jsonData);
                            
                        } catch {
                            print("jsonData not successful for pin set");
                        }
                        
                        //Successful post!
                        if(res?.statusCode == 200) {
                            self.setPinValue(pinNumber, value: newState);
                        } else {
                            print("Response status fail: " + String(describing: res?.statusCode));
                            cell.onState.isOn = !cell.onState.isOn;
                        }
                    }
                
                    print("urlData: \(urlData)");
                    print("res: \(res)");
                    
                    //Status code: 200 is inside 'res' somewhere, THAT is what will tell me if we were successful
                
                    cell.onState.isEnabled = true;
                    cell.spinner.stopAnimating();
                
            } // end dispatch
            self.getPins();
        } // end task
        task.resume();
    }
*/
    func printPinList()
    {
        for p in tabBarPins {
            print("\(p.name) \(p.stateName) \(p.type)");
        }
        print("");
    }
    /*
    //sets one pin to HIGH or LOW (not on the pi, just in this program)
    func setPinValue(_ pinNumber: Int, value: Bool)
    {
        tabBarPins[pinNumber].on = value;
        let optionView = OptionTableViewController()
        let pinView = PinTableViewController()
        
        optionView.pins[pinNumber].on = value;
        pinView.pins[pinNumber].on = value;
        
        optionView.tableView.reloadData();
        pinView.tableView.reloadData();
    }
    */
}
