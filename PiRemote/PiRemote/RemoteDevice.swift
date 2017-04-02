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

    // Descriptions can be found at http://docs.weaved.com/docs/devicelistall
    var deviceAddress: String
    var deviceAlias: String
    var deviceLastip: String
    var deviceState: String
    var deviceType: String
    var lastInternalip: String
    var localUrl: String
    var ownerUsername: String
    var serviceTitle: String
    var webEnabled: String

    init() {
        deviceAddress = ""
        deviceAlias = ""
        deviceLastip = ""
        deviceState = ""
        deviceType = ""
        lastInternalip = ""
        localUrl = ""
        ownerUsername = ""
        serviceTitle = ""
        webEnabled = "0" // = false
    }

    init(deviceData: NSDictionary) {
        deviceAddress = deviceData["deviceaddress"] as! String
        deviceAlias = deviceData["devicealias"] as! String
        deviceLastip = deviceData["devicelastip"] as! String
        deviceState = deviceData["devicestate"] as! String
        deviceType = deviceData["devicetype"] as! String
        lastInternalip = deviceData["lastinternalip"] as! String
        localUrl = deviceData["localurl"] as! String
        ownerUsername = deviceData["ownerusername"] as! String
        serviceTitle = deviceData["servicetitle"] as! String
        webEnabled = deviceData["webenabled"] as! String
    }
}

