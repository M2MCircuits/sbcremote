//
//  OptionTableViewController.swift
//  PiRemote
//
//  Authors: Hunter Heard, Josh Binkley
//  Copyright (c) 2016 JLL Consulting. All rights reserved.
//

import UIKit

// DEPRECATED: No connection to storyboard. Only business logic has been preserved.
// TODO: Evaluate code to see what can be learned/reused
class OptionTableViewController {

    var pins = [Pin]()

    //if the "type" button on a cell is pressed
    //this function will use the button's tag
    //as an index for pins and change that pin's type
    @IBAction func typeButtonPress(_ sender: UIButton) {
        
        if(sender.tag < 0 || sender.tag >= pins.count)
        {
            return;
        }
        
        let tbc = MyTabBarController()

        sender.isEnabled = false;
        
        tbc.setFunction(sender, newFunction: !pins[sender.tag].function)

        //Where's that list of webiopi http commands?
    }
    
    
    @IBAction func nameChange(_ sender: UITextField) {
        
        if(sender.tag < 0 || sender.tag >= pins.count)
        {
            return;
        }
        pins[sender.tag].setHname(sender.text!);
        
        let tbc = MyTabBarController()
        let otherView = tbc.childViewControllers[0] as! PinTableViewController;
        otherView.getCellForPinNumber(sender.tag).nameLabel.text=sender.text;
        otherView.getCellForPinNumber(sender.tag).setNeedsDisplay();
        
        otherView.pins = self.pins;
        tbc.tabBarPins = pins;
    }
    
    
    @IBAction func HnameChange(_ sender: UITextField) {
        if(sender.tag < 0 || sender.tag >= pins.count)
        {
            return;
        }
        
        pins[sender.tag].setHname(sender.text!);
        
        let tbc = MyTabBarController()
        let otherView = PinTableViewController()
        otherView.getCellForPinNumber(sender.tag).Hlabel=sender.text;
        otherView.getCellForPinNumber(sender.tag).setNeedsDisplay();
        
        otherView.pins = self.pins;
        tbc.tabBarPins = pins;
        
        //syncWithTable();

    }

    
    @IBAction func LnameChange(_ sender: UITextField) {
        if(sender.tag < 0 || sender.tag >= pins.count)
        {
            return;
        }
        
        pins[sender.tag].setLname(sender.text!);
        
        let tbc = self.parent as! MyTabBarController;
        let otherView = tbc.childViewControllers[0] as! PinTableViewController;
        otherView.getCellForPinNumber(sender.tag).Llabel=sender.text;
        otherView.getCellForPinNumber(sender.tag).setNeedsDisplay();
        
        otherView.pins = self.pins;
        tbc.tabBarPins = pins;
        
        //syncWithTable();

    }
    
    
    /*
    @IBAction func typeButtonPress(sender: UIButton) {
        
        if(sender.tag < 0 || sender.tag >= pins.count)
        {
            return;
        }
        
        pins[sender.tag].changeType();
        
        
    }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if pins.count == 0
        {
            
            //loadSamplePins();
            
//            var tempPin = Pin();
//            for i in 1...8
//            {
//                pins += [tempPin];
//            }
        }
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func loadSamplePins()
    {
        let pin1 = Pin(name: "Water", Hname: "Flow", Lname: "Stop", type: 1)
        let pin2 = Pin(name: "Light", Hname: "On", Lname: "Off", type: 1)
        let pin3 = Pin(name: "Door", Hname: "Open", Lname: "Closed", type: 2)
        let pin4 = Pin(name: "Bulb", Hname: "On", Lname: "Off", type: 1)
        let pin5 = Pin(name: "Garage Sensor", Hname: "Motion", Lname: "Still", type: 2)
        let pin6 = Pin(name: "Flood Sensor", Hname: "Flooded", Lname: "Not Flooded", type: 2)
        let pin7 = Pin(name: "Sprinkler", Hname: "Running", Lname: "Off", type: 1)
        let pin8 = Pin(name: "Stove", Hname: "On", Lname: "Off", type: 1)
        
        pins += [pin1,pin2,pin3,pin4,pin5,pin6,pin7,pin8];
    }
    
    func numberOfMonitorPins() -> Int
    {
        var n = 0;
        
        for p in pins{
            if(!p.function && p.isGPIO)
            {
                n += 1;
            }
            
        }
        
        return n;
    }
    
    func numberOfControlPins() -> Int
    {
        var n = 0;
        
        for p in pins{
            if(p.function && p.isGPIO)
            {
                n += 1;
            }
            
        }
        
        return n;
    }
    
    func printPinList()
    {
        for p in pins{
            print(p.name, terminator: "");
            print(" ", terminator: "");
            print(p.stateName, terminator: "");
            print("");
        }
        print("");
    }
    
    
    //what does this do here?
    func getPinDegree(_ type: Int, degree: Int) -> Int
    {
        
        var count = -1;
        var I = 0;
        for p in pins{
            
            if(p.type == type && p.isGPIO)
            {
                count += 1;
                
                if(count == degree)
                {
                    return I;
                }
                
            }
            
            I += 1;
        }
        
        return -1;
    }
}
