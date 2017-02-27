//
//  MainUser.swift
//  PiRemote
//
//  Created by Victor Anyirah on 2/22/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import Foundation



class MainUser{
    
    static let sharedInstance = MainUser()
   
    private init(){}

    // Weaved
    var email : String?
    var apiKey: String?
    var token: String?

    func getUserInformationFromResponse(dictionary : NSDictionary){
        self.email = dictionary["email"] as? String
        self.apiKey = dictionary["apiKey"] as? String
        self.token = dictionary["token"] as? String
    }
}
