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
                        ]
        // Warning. BaseURL is not valid.
        let url = AppEngineConstants.BaseURL + "/account/" + device.apiData["deviceAddress"]!
        self.api.postRequest(url: url, extraHeaderFields: nil, payload: jsonBody as [String : AnyObject]?) { (data) in
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
    
    func registerPhoneToken(phoneToken : Data, completion: @escaping (_ sucess: Bool)-> Void){
        let param = ["token" : "\(phoneToken)",
                    "email" : MainUser.sharedInstance.email]
        //Warning: Currently does not work.
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
    
    
    
    
    
    
}
