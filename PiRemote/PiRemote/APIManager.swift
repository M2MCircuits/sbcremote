//
//  APIManager.swift
//  PiRemote
//
//  Created by Victor Anyirah on 1/28/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

class APIManager {
    /**
     Class dedicated to interacting with the Weaved API.
    */
    var simpleHTTP : SimpleHTTPRequest!
    
    init() {
        self.simpleHTTP = SimpleHTTPRequest()
    }
    
    //TODO : Validate parameters or change as needed.
    func logIntoWeavedAccount(userName: String, password: String, completion: (sucess: Bool, data: NSData?)-> Void){
        //TODO : Implement.
    }
    
    
    func getWeavedDeviceList(){
        //TODO: Implement
    }
    
}
