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
    
    func getRequest(url: String, extraHeaderFields: [String: String]?, payload: [String: Any]? = nil, completion: @escaping (_ data: Any?) -> Void) {

        self.network.simpleAPIRequest(toUrl: url, HTTPMethod: "GET", jsonBody: payload, extraHeaderFields: extraHeaderFields, completionHandler: {
            sucess, data, err in
            
            if sucess{
                completion(data!)
            }else{
                print(err.debugDescription)
                completion(nil)
            }
        })
    }

    func postRequest(url: String, extraHeaderFields: [String: String]?, payload: [String: Any]?, completion: @escaping (_ data: Any?) -> Void) {

        self.network.simpleAPIRequest(toUrl: url, HTTPMethod: "POST", jsonBody: payload, extraHeaderFields: extraHeaderFields, completionHandler: {
            sucess, data, err in

            if sucess{
                completion(data!)
            }else{
                print(err.debugDescription)
                completion(nil)
            }
        })
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
