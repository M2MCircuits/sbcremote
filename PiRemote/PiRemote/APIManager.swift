//
//  APIManager.swift
//  PiRemote
//
//  Created by Victor Anyirah on 2/3/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import Foundation


class APIManager{
    
    let network = SimpleHTTPRequest()
    
    func getRequest(url: String, completion: @escaping (_ data: NSDictionary?)-> Void){
        self.network.simpleAPIRequest(toUrl: url, HTTPMethod: "GET", jsonBody: nil) { sucess, data, err in
            if sucess{
                guard self.checkResponse(data: data!) != false else{
                    completion(nil)
                    return
                }
                completion(data!)
                
            }
        }
        
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
    
    
    /**
     Escapes information in a dictionary and returns string. Works for parameters or JSON Body.
     
     - parameter jsonBody: (Bool), parameters(Dictionary)
     - returns: String
     */
    func escapedParameters(jsonBody: Bool, parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            var stringValue = "\(value)"
            
            //Forced unwrapping occuring. Is there a case where it would fail?
            if (!jsonBody){
                stringValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            }
            /* Append it */
            urlVars += [key + "=" + "\(stringValue)"]
            
        }
        
        return (!urlVars.isEmpty ? "" : "") + urlVars.joined(separator: "&")
    }
    
}
