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

    
    let SucessResponse = "Sucessfully logged in!"
    let ErrorResponse = "There was an error logging in"
    
    init() {
        self.baseApiUrl = "https://api.weaved.com/v22/api"
        self.API = APIManager()
    }


    // GET user/login/:username/:password
    func logInUser(username: String, userpw: String, callback: @escaping (_ sucess : Bool, _ response: String, _ data: NSDictionary?) -> Void){
        let endpointURL = "/user/login/" + username + "/" + userpw
        let weavedHeaderFields = ["apikey" : "WeavedDemoKey$2015"]
        self.API.getRequest(url: baseApiUrl + endpointURL, extraHeaderFields: weavedHeaderFields, completion: { data in
        
            guard data != nil else{
                callback(false, self.ErrorResponse, nil)
                return
            }
            
            var response : String
            if self.checkResponse(data: data!) == true{
                response = self.SucessResponse
                callback(true, response, data!)
            }
            else{
                response = data!["reason"] as! String
                // If it fails we simply show the string. No need to show the data.
                callback(false, response, nil)
            }
        })
    }

    
    /**
     Checks if the returned data was a sucessful result.
     Does not check if the network actually made connection, but instead if the response is sucessful
     
     - parameter data,: NSDictionary
     - returns: Bool indicating if the the communication was sucessful or not.
     */
    func checkResponse(data: NSDictionary)->Bool{
        let returnedData = data["status"] as! String
        //f represents failure.
        if returnedData[returnedData.startIndex] != "f"{
            return true
        }else{
            return false
        }
    }
    
    
    func sendDevice(deviceAddress: String, command: String?, completion: @escaping (_ sucess: Bool) -> Void){
        //TODO : Implement
    }
    
    func connectDevice(deviceAddress: String, hostip: String, shouldWait: Bool, completion: (_ data: NSDictionary?)->Void){
        //TODO : Implement
    }
    

    // GET device/list/all
    func listDevices(token: String, callback: @escaping (_ data: NSDictionary?) -> Void) {
        let endpointURL = "/device/list/all"
        let weavedHeaderFields = ["apikey" : "WeavedDemoKey$2015", "token" : token]
        self.API.getRequest(url: baseApiUrl + endpointURL, extraHeaderFields: weavedHeaderFields, completion: {data in
            guard data != nil else{
                callback(nil)
                return
            }
            
            if self.checkResponse(data: data!) == true{
                callback(data!)
            }else{
                callback(nil)
            }
            
            
        })
    }
    
    

}
