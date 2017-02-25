//
//  WeavedDeviceManager.swift
//  PiRemote
//
//  Created by Victor Anyirah on 2/22/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import Foundation


class WeavedDeviceManager{
    
    
    func createDevicesFromAPIResponse(data : NSDictionary) ->(SSH: [WeavedDevice], NOTSSH: [WeavedDevice]){
        var SSHdeviceStorage = [WeavedDevice]()
        var deviceStorage = [WeavedDevice]()
        let devices = data["devices"] as! NSArray
        for deviceData in devices{
            let device = WeavedDevice(deviceData: deviceData as! NSDictionary)
            if device.service == "SSH"{
                SSHdeviceStorage.append(device)
            }else{
                deviceStorage.append(device)
            }
        }
        return (SSHdeviceStorage, deviceStorage)
    }
    

}
