//
//  Pin.swift
//  Attempt2
//
//  Created by Hunter Heard on 3/31/16.
//  Copyright (c) 2016 Hunter Heard. All rights reserved.
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
    
    //false = IN, true = OUT
    var function: Bool
    
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
        self.function = false;
        self.isGPIO = false;
        
        if(type == 1)
        {
            self.function = true;
        }
        
        self.on = false;
        
        
    }
    
    init() {
        
        self.name = "label";
        self.Hname = "On";
        self.Lname = "Off";
        self.type = 0;
        self.stateName = "Off";
        self.function = false;
        self.isGPIO = false;
        
        
        self.on = false;
        
        
    }
    
    func changeFunction(_ newF: Bool)
    {
        function = newF;
        
        if(type != 0)
        {
            if(function)
            {
                type = 1;
            }
            else
            {
                type = 2;
            }
        }
        
        
    }
    
    func typeFunction(_ t: Int) -> Bool
    {
        if(t == 1)
        {
            return true;
        }
        
        return false;
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
    
    /**
     * data: {value: 0 or 1, function: "IN" or "OUT"}
     */
    func setFromData(_ data: NSDictionary)
    {
        print("\nPin setting data from outside");
        
        // value can either be 0 or 1
        on = data.value(forKey: "value") as! Bool;
        print("Value set to ", terminator: "");
        stateName = Lname;
        
        if(on)
        {
            stateName = Hname;
        }
        
        print(stateName);
        
        let t = data.value(forKey: "function") as! String;
        
        type = 0;
        
        if(t == "IN")
        {
            type = 2;
            function = false;
        }
        
        if(t == "OUT")
        {
            type = 1;
            function = true;
        }
        
        
        
        
        
        typeFunction(type);
        
        print("Type set to ", terminator: "");
        print(type);
        return;
        
    }
    
    func changeType()
    {
        
        type = type + 1;
        
        if(type > 2)
        {
            type = 1;
        }
        
        function = typeFunction(type);
        
        
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
