//
//  Pin.swift
//  PiRemote
//
//  Authors: Hunter Heard, Josh Binkley
//  Copyright (c) 2016 JLL Consulting. All rights reserved.
//

import UIKit


class Pin {
    
    // MARK: Properties
    
    //Each pin needs the following
    // Type: Control, Monitor, or Ignore
    // Name
    // Name of High
    // Name of Low
    
    var name: String
    
    var Hname: String
    var Lname: String
    var stateName: String
    var type: Int
    var gpioNumber: Int

    //false = IN, true = OUT
    var function: String

    // TODO: Based on old MyTabBarController code, omit pins 0, 1, 14, 15, 27+ and set type to 0.
    var isGPIO: Bool

    //type 0: Ignore
    //type 1: Control
    //type 2: Monitor

    var on: Bool
    
    
    // MARK: Initialization
    
    init(name: String, Hname: String, Lname: String, type: Int) {
        
        self.name = name;
        self.Hname = Hname;
        self.Lname = Lname;
        self.type = type;
        self.stateName = Lname;
        self.function = "IN";
        self.isGPIO = false;
        self.gpioNumber = -1;
        
        if(type == 1)
        {
            self.function = "OUT";
        }
        
        self.on = false;
    }
    
    init() {
        
        self.name = "label";
        self.Hname = "On";
        self.Lname = "Off";
        self.type = 0;
        self.stateName = "Off";
        self.function = "IN";
        self.isGPIO = false;
        self.on = false;
        self.gpioNumber = -1;
        
    }
    
    func changeFunction(_ newF: String)
    {
        function = newF;
        
        if(type != 0)
        {
            if(function == "OUT")
            {
                type = 1;
            }
            else
            {
                type = 2;
            }
        }
    }

    func changeState()
    {
        if(on)
        {
            on = false;
            stateName = Lname;
            return;
        }
        
        on = true;
        stateName = Hname;
        return;
    }
    
    func setFromData(_ data: [String: AnyObject]) -> Pin
    {
        function = data["function"] as! String;
        on = data["value"] as! Bool;
        stateName = on ? Hname : Lname;

        if(function == "IN") { 
            type = 2
        } else if(function == "OUT") {
            type = 1
        } else {
            type = 0
        }

        return self
    }
    
    func changeType()
    {
        type = type + 1;
        
        if(type > 2)
        {
            type = 1;
        }
        
        function = type == 1 ? "OUT" : "IN";
    }
    
    func setName(_ newName: String)
    {
        name = newName;
    }
    
    func setHname(_ newName: String)
    {
        Hname = newName;
    }
    
    func setLname(_ newName: String)
    {
        Lname = newName;
    }

    func setGPIONumber(_ newNumber: Int) -> Pin {
        gpioNumber = newNumber;
        return self
    }
    
    
    class func getEmpty() -> [Pin]
    {
        var pins = [Pin]();
        
        var p = Pin(name: "label", Hname: "On", Lname: "Off", type: 0);
        
        for _ in 1...28
        {
            p = Pin(name: "label", Hname: "On", Lname: "Off", type: 0);//without this line, pins will be an array full of references to the same one pin
            pins += [p];
        }
        
        return pins;
    }
    
}
