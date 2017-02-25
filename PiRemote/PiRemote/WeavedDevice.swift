//
//  WeavedDevice.swift
//  PiRemote
//
//  Authors: Hunter Heard, Josh Binkley
//  Copyright (c) 2016 JLL Consulting. All rights reserved.
//

import Foundation

import UIKit


class WeavedDevice{
    
    
    var alias: String;
    var address: String;
    var ownerUserName: String;
    var state: String;
    var service : String
    
    
    init(deviceData: NSDictionary)
    {
        alias = deviceData["devicealias"] as! String;
        address = deviceData["deviceaddress"] as! String;
        ownerUserName = deviceData["ownerusername"] as! String;
        state = deviceData["devicestate"] as! String
        service = deviceData["servicetitle"] as! String
    }
    
    
}

