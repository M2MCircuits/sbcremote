//
//  WeavedAPIManager.swift
//  PiRemote
//
//  Created by Victor Anyirah on 2/3/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import Foundation


class RemoteAPIManager {

    var api : APIManager!
    var baseApiUrl : String!
    var token : String?
    var remoteHeaderFields: [String: String]

    let SucessResponse = "Sucessfully logged in!"
    let ErrorResponse = "There was an error logging in"
    
    init() {
        api = APIManager()
        baseApiUrl = "https://api.weaved.com/v22/api"
        remoteHeaderFields = [
            "apikey": "WeavedDemoKey$2015",
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }


    // GET user/login/:username/:password
    func logInUser(username: String, userpw: String, callback: @escaping (_ sucess : Bool, _ response: String, _ data: NSDictionary?) -> Void){
        let endpointURL = "/user/login/" + username + "/" + userpw

        self.api.getRequest(url: baseApiUrl + endpointURL, extraHeaderFields: remoteHeaderFields, completion: { data in
        
            guard data != nil else{
                callback(false, self.ErrorResponse, nil)
                return
            }
            
            var response : String
            let jsonData = data as! NSDictionary
            if self.checkResponse(data: jsonData) == true{
                response = self.SucessResponse
                callback(true, response, jsonData)
            }
            else{
                response = jsonData["reason"] as! String
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
    
    func connectDevice(deviceAddress: String, hostip: String, shouldWait: Bool, callback: @escaping (_ data: NSDictionary?) -> Void) {
        let endpointURL = "/device/connect"
        let payload = [
            "deviceaddress": deviceAddress,
            "hostip": hostip,
            "wait": String(shouldWait)
        ] as [String : Any]

        let remoteHeaderFieldsPost = [
            "apikey": "WeavedDemoKey$2015",
            "content-type": "application/json",
            "token": MainUser.sharedInstance.weavedToken!
        ]

        self.api.postRequest(url: baseApiUrl + endpointURL, extraHeaderFields: remoteHeaderFieldsPost, payload: payload, completion: { data in
            guard data != nil else {
                callback(nil)
                return
            }

            let jsonData = data as! NSDictionary
            if self.checkResponse(data: jsonData) == true {
                callback(jsonData)
            } else {
                callback(nil)
            }
        })
    }
    

    // GET device/list/all
    func listDevices(token: String, callback: @escaping (_ data: NSDictionary?) -> Void) {
        let endpointURL = "/device/list/all"
        remoteHeaderFields["token"] = token
        self.api.getRequest(url: baseApiUrl + endpointURL, extraHeaderFields: remoteHeaderFields, completion: { data in
            guard data != nil else {
                callback(nil)
                return
            }

            let jsonData = data as! NSDictionary
            if self.checkResponse(data: jsonData) == true {
                callback(jsonData)
            } else {
                callback(nil)
            }
        })
    }
}
