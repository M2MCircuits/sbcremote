//
//  AppEngineManager.swift
//  PiRemote
//
//  Created by Victor Anyirah on 3/15/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import Foundation

class AppEngineManager {
    
    
    var api : APIManager
    
    init(){
        api = APIManager()
    }

    
    func registerPhoneToken(phoneToken : String,  completion: @escaping (_ sucess: Bool)-> Void){
        // We need to update all devices the account has with the phone token. 
        // Get device_list, push that to account. 
        // Get service_ids via email. Update the phone token in all of them.
        guard MainUser.sharedInstance.email != nil else{
            print("Email is nil. Cannot send data.")
            completion(false)
            return
        }
        
        let param = ["token" : "\(phoneToken)",
                    "email" : MainUser.sharedInstance.email!]

        let url = AppEngineConstants.BaseURL + "/token"
        self.api.postRequest(url: url, extraHeaderFields: nil, payload: param as [String : AnyObject]?) { (data) in
            
            guard data != nil else{
                completion(false)
                return
            }

            guard let jsonData = data as! NSDictionary? else{
                completion(false)
                return
            }
            
            if jsonData["response"] as! String == "Sucess"{
                completion(true)
            }else{
                completion(false)
            }
        }
        
    }
    
    func createAccountsForDevices(devices: [RemoteDevice], email: String, completion: ((_ success: Bool)->Void)?) {
        var serviceHash = [String : String]()
        for device in devices{
            serviceHash[device.apiData[DeviceAPIType.deviceAddress]!] = device.apiData[DeviceAPIType.deviceAlias]!
        }

        let url = AppEngineConstants.BaseURL + "/accounts"
        let jsonBody = ["email" : email,
                        "service_ids" : serviceHash] as [String : Any]
        self.api.postRequest(url: url, extraHeaderFields: nil, payload: jsonBody as [String : AnyObject]?) { (data) in
            guard data != nil else {
                completion?(false)
                return
            }
            
            guard let jsonData = data as! NSDictionary? else {
                completion?(false)
                return
            }

            if jsonData["response"] as! String == "Sucess" {
                completion?(true)
            }else{
                completion?(false)
            }
        }
        
    }
    
    
    
    
    
    
}
