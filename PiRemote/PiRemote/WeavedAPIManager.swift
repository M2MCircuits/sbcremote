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
    
    
    
}
