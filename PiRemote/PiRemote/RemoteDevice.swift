//
//  RemoteITDevice.swift
//  PiRemote
//
//  Authors: Hunter Heard, Josh Binkley, Muhammad Martinez
//  Copyright (c) 2016 JLL Consulting. All rights reserved.
//

import Foundation

import UIKit


class RemoteDevice{
    
    
    var alias: String;
    var address: String;
    var ownerUserName: String;
    var state: String;
    var service : String
    
    init()
    {
        alias = ""
        address = ""
        ownerUserName = ""
        state = ""
        service = ""
    }

    init(deviceData: NSDictionary)
    {
        alias = deviceData["devicealias"] as! String;
        address = deviceData["deviceaddress"] as! String;
        ownerUserName = deviceData["ownerusername"] as! String;
        state = deviceData["devicestate"] as! String
        service = deviceData["servicetitle"] as! String
    }
    
    
}

