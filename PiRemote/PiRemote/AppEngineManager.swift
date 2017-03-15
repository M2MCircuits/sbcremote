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
    
    
    func postDeviceInfo(device: RemoteDevice, completion: @escaping (_ sucess : Bool) -> Void){
        let user = MainUser.sharedInstance
        let jsonBody = ["email" : user.email!,
                        "service_id" : device.deviceAddress,
                        ]
        self.api.postRequest(url: AppEngineConstants.BaseURL, extraHeaderFields: nil, payload: jsonBody as [String : AnyObject]?) { (data) in
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
    
    func 
    
    
    
    
    
    
}
