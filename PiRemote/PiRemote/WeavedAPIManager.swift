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
    
    init() {
        self.baseApiUrl = "https://api.weaved.com/v22/api"
        self.API = APIManager()
    }

    // GET user/login/:username/:password
    func logInUser(username: String, userpw: String, callback: @escaping (_ data: NSDictionary?) -> Void){
        let endpointURL = "/user/login/" + username + "/" + userpw
        let weavedHeaderFields = ["apikey" : "WeavedDemoKey$2015"]
        self.API.getRequest(url: baseApiUrl + endpointURL, extraHeaderFields: weavedHeaderFields, completion: callback)
    }

    // GET device/list/all
    func listDevices(token: String, callback: @escaping (_ data: NSDictionary?) -> Void) {
        let endpointURL = "/device/list/all"
        let weavedHeaderFields = ["apikey" : "WeavedDemoKey$2015", "token" : token]
        self.API.getRequest(url: baseApiUrl + endpointURL, extraHeaderFields: weavedHeaderFields, completion: callback)
    }

}
