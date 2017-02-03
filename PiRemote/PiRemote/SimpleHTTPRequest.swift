//
//  SimpleHTTPRequest.swift
//  PiRemote
//
//  Created by Victor Anyirah on 2/3/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import Foundation


class SimpleHTTPRequest : NSObject {
    
    
    func simpleAPIRequest(toUrl: String, HTTPMethod: String, jsonBody: [String: AnyObject]?, completionHandler: @escaping (_ sucess: Bool, _ data: NSDictionary?, _ error: Error?)->Void){
        
        //Creates URL Session
        let session = URLSession.shared
        
        //If the url is not valid, we fail and return.
        guard let url = URL(string: toUrl) else {
            completionHandler(false, nil, nil)
            return
        }
        
        //Creates request with fields set for JSON
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //Serializes any parameters in the httpbody if there are any.
        if let HTTPBody = jsonBody{
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: HTTPBody, options: [])
            } catch _ as NSError {
                request.httpBody = nil
            }
        }
        
        
        //Retrieves data returned.
        let task = session.dataTask(with: request as URLRequest){
            data, response, downloadError in
            if let error = downloadError {
                completionHandler(false, nil, downloadError)
                print("Error communicating with server via HTTP")
                print(error)
            }
            else{
                var jsonResult : Any?
                do{
                    jsonResult = try JSONSerialization.jsonObject(with: data!, options: [])
                    completionHandler(true, jsonResult as? NSDictionary, nil)
                }catch{
                    completionHandler(false, nil, nil)
                }
            }
        }
        task.resume()
        
    }
    
}
