//
//  PinTableViewController.swift
//  PiRemote
//
//  Authors: Hunter Heard, Josh Binkley
//  Copyright (c) 2016 JLL Consulting. All rights reserved.
//

import UIKit

// DEPRECATED: No connection to storyboard. Only business logic has been preserved.
// TODO: Evaluate code to see what can be learned/reused
class PinTableViewController {
    
    //MARK Properties
    var pins = [Pin]();
    
    @IBAction func switchHit(_ sender: PinUISwitch) {

        print("YOU SWITCH DEVIL!");
        
        let number = sender.pinNumber;
        let tbc = MyTabBarController()

        if(sender.pinNumber < 0 || sender.pinNumber >= pins.count)
        {
            return;
        }
        
        //send request to raspberry pi to change state
        sender.isEnabled = false;
        
        //tbc.setPin(number!, newState: !pins[number!].on);

        //pins[sender.pinNumber].changeState();
        //printPinList();
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
            if(p.type == 2)
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
            if(p.type == 1)
            {
                n += 1;
            }
            
        }
        
        return n;
    }
    
    func numberOfPinsOfType(_ type: Int) -> Int
    {
        if(type == 0)
        {
            return pins.count - numberOfControlPins() - numberOfMonitorPins();
        }
        
        if(type == 1)
        {
            return numberOfControlPins();
        }
        
        if(type == 2)
        {
            return numberOfMonitorPins();
        }
        
        return 0;
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
    
    
    //gets the pin number of the pin that belongs in the section and row
    //(except here it's type instead of section
    //if section == 0 then type == 1
    //if section == 1 then type == 2
    func getPinDegree(_ type: Int, degree: Int) -> Int
    {
        
        var count = -1;
        var I = 0;
        for p in pins{
            
            if(p.type == type)
            {
                count = count + 1;
                
                if(count == degree)
                {
                    return I;
                }
                
            }
            
            I = I + 1;
        }
        
        return -1;
    }
}
