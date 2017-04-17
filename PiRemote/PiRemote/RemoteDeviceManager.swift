//
//  RemoteDeviceManager.swift
//  PiRemote
//
//  Created by Victor Anyirah on 2/22/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import Foundation


class RemoteDeviceManager{
    
    
    func createDevicesFromAPIResponse(data: NSDictionary) -> [RemoteDevice] {
        let allDevices = data["devices"] as! NSArray

        // We can only control devices with using HTTP
        return allDevices.filter({ currentDevice in
            ((currentDevice as! NSDictionary)["servicetitle"] as! String) == "HTTP"
        }).map({ httpDevice in
            return RemoteDevice(deviceData: httpDevice as! NSDictionary)
        })
    }
    

}
