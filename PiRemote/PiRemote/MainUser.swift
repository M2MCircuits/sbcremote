//
//  MainUser.swift
//  PiRemote
//
//  Created by Victor Anyirah on 2/22/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import Foundation

class MainUser {
    
    static let sharedInstance = MainUser()
   
    private init(){}

    // Remot3.it
    var email : String?
    var apiKey: String?
    // Phone token
    var token: String?
    var currentDevice: RemoteDevice?
    var layouts: [PinLayout]?

    func getUserInformationFromResponse(dictionary : NSDictionary) {
        self.email = dictionary["email"] as? String
        self.apiKey = dictionary["apiKey"] as? String
        self.token = dictionary["token"] as? String
    }
    
    //TODO : Save in NSUserDefaults.
    
}
