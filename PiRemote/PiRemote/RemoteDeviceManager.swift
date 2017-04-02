//
//  RemoteDeviceManager.swift
//  PiRemote
//
//  Created by Victor Anyirah on 2/22/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import Foundation


class RemoteDeviceManager{
    
    
    func createDevicesFromAPIResponse(data: NSDictionary) ->(SSH: [RemoteDevice], NOTSSH: [RemoteDevice]){
        var SSHdeviceStorage = [RemoteDevice]()
        var deviceStorage = [RemoteDevice]()
        let devices = data["devices"] as! NSArray
        for deviceData in devices{
            let device = RemoteDevice(deviceData: deviceData as! NSDictionary)
            if device.serviceTitle == "SSH"{
                SSHdeviceStorage.append(device)
            }else{
                deviceStorage.append(device)
            }
        }
        return (SSHdeviceStorage, deviceStorage)
    }
    

}
