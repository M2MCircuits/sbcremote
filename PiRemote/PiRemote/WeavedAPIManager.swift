//
//  WeavedAPIManager.swift
//  PiRemote
//
//  Created by Victor Anyirah on 2/3/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import Foundation


class WeavedAPIManager {
    
    var baseApiUrl : String!
    var API : APIManager!
    var token : String?
    
    init() {
        self.baseApiUrl = "https://api.weaved.com/v22/api"
        self.API = APIManager()
    }
    
    func logInUser(username: String, userpw: String, completion: @escaping (_ sucess: Bool) -> Void){
        let endpointURL = "/user/login/" + username + "/" + userpw
        self.API.getRequest(url: baseApiUrl + endpointURL) { (data) in
            if (data != nil){
                //TODO: Handle data
                completion(true)
            }
            else{
                completion(false)
            }
        }
    }
    
    
    func listDevices(completion: @escaping (_ data : NSDictionary?) -> Void){
        guard self.token != nil else{
            completion(nil)
            return
        }
        let deviceURL = "device/list/all"
        let endURL = self.baseApiUrl + "/" + deviceURL
        //TODO ; Look at this again. Not the best.
        self.API.getRequest(url: endURL) { (data) in
            completion(data)
        }
    }
    
    func sendDevice(deviceAddress: String, command: String?, completion: @escaping (_ sucess: Bool) -> Void){
        //TODO : Implement
    }
    
    func connectDevice(deviceAddress: String, hostip: String, shouldWait: Bool, completion: (_ data: NSDictionary?)->Void){
        //TODO : Implement
    }
    
}
