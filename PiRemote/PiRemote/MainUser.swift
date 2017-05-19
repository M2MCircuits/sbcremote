//
//  MainUser.swift
//  PiRemote
//
//  Created by Victor Anyirah on 2/22/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//
import UIKit
import Foundation

class MainUser{
    
    static let sharedInstance = MainUser()
   
    private init(){}
    
    // Remot3.it
    var email : String?
    
    // Weird. Apparently this is the global API key and they specified they planned on having individual keys in the future..but I didn't find anything
    // in the docs
    // see : http://docs.weaved.com/v21/discuss/577bde161cf3cb0e0048e357
    var apiKey: String = "WeavedDemoKey$2015"
    
    var weavedToken : String?
    
    var password: String?
    // Phone token
    // Set by notification system.
    var phone_token: String?
    var currentDevice: RemoteDevice?
    var layouts: [PinLayout]?

    func getUserInformationFromResponse(dictionary : NSDictionary) {
        self.email = dictionary["email"] as? String
        self.weavedToken = dictionary["token"] as? String
    }
    
    
    func saveUser(){

        KeychainWrapper.standard.set(self.email!, forKey: "user_email")
        KeychainWrapper.standard.set(self.password!, forKey: "user_pw")
        KeychainWrapper.standard.set(self.weavedToken!, forKey: "weaved_token")
        if (self.layouts != nil){
            let layoutData = NSKeyedArchiver.archivedData(withRootObject: self.layouts!)
            UserDefaults.standard.set(layoutData, forKey: "user_layout")
        }
        UserDefaults.standard.synchronize()
    }
    
    func savePhoneToken(){
        if self.phone_token != nil{
            KeychainWrapper.standard.set(self.phone_token!, forKey: "phone_token")
        }
    }
    
    func loadSaved()->Bool{
        guard let email = KeychainWrapper.standard.string(forKey: "user_email"),
            let token = KeychainWrapper.standard.string(forKey: "weaved_token"),
            let password = KeychainWrapper.standard.string(forKey: "user_pw")
            else{
                return false
        }
        self.email = email
        self.weavedToken = token
        self.password = password
        if let phone_token = KeychainWrapper.standard.string(forKey: "phone_token"){
            self.phone_token = phone_token
        }else{
            self.phone_token = nil
        }
        if let layoutData = UserDefaults.standard.object(forKey: "user_layout") as? Data{
            self.layouts = NSKeyedUnarchiver.unarchiveObject(with: layoutData) as? [PinLayout]
        }else{
            self.layouts = nil
        }
        return true
    }

}
