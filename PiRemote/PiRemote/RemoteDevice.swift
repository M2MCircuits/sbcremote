//
//  RemoteDevice.swift
//  PiRemote
//
//  Authors: Muhammad Martinez
//  Copyright (c) 2016 JLL Consulting. All rights reserved.
//

import Foundation

class RemoteDevice: NSObject, NSCoding {

    

    // Descriptions can be found at http://docs.weaved.com/docs/devicelistall
    var apiData: [String: String]!

    // Local Variables
    var layout: PinLayout!
    var shouldPersistState: Bool! // Attempt to restore previous pin values on restart
    var stateJson: [String: [String:AnyObject]]!

    override init() {
        super.init()
    }

    required init(coder decoder: NSCoder) {
        self.apiData = decoder.decodeObject(forKey: "apiData") as! [String:String]
        self.layout = decoder.decodeObject(forKey: "layout") as! PinLayout
        self.shouldPersistState = decoder.decodeObject(forKey: "shouldPersistState") as! Bool
        self.stateJson = decoder.decodeObject(forKey: "stateJson") as! [String: [String:AnyObject]]
    }

    init(deviceData: NSDictionary) {
        self.apiData = [String: String]()
        self.apiData["deviceAddress"] = deviceData["deviceaddress"] as? String
        self.apiData["deviceAlias"] = deviceData["devicealias"] as? String
        self.apiData["deviceLastIP"] = deviceData["devicelastip"] as? String
        self.apiData["deviceState"] = deviceData["devicestate"] as? String
        self.apiData["deviceType"] = deviceData["devicetype"] as? String
        self.apiData["lastInternalIP"] = deviceData["lastinternalip"] as? String
        self.apiData["localUrl"] = deviceData["localurl"] as? String
        self.apiData["ownerUsername"] = deviceData["ownerusername"] as? String
        self.apiData["serviceTitle"] = deviceData["servicetitle"] as? String
        self.apiData["webEnabled"] = deviceData["webenabled"] as? String
    }

    func encode(with coder: NSCoder) {
        coder.encode(apiData, forKey: "apiData")
        coder.encode(layout, forKey: "layout")
        coder.encode(shouldPersistState, forKey: "shouldPersistState")
        coder.encode(stateJson, forKey: "stateJson")
    }
}
