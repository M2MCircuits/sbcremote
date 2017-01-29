//
//  SimpleHTTPRequest.swift
//  PiRemote
//
//  Created by Victor Anyirah on 1/28/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

class SimpleHTTPRequest: NSObject {

    /**
     Base request function for communicating with sever via HTTP. Only for simple, non-media related transmission
     
     - parameter url: (String), HTTPMethod(String), jsonBody([String: AnyObject], completionhandler
     - returns: success, error, dictionary optional with json information via callback.
     */
    
    func simpleHTTPRequest(toUrl: String, HTTPMethod: String, jsonBody: [String: AnyObject]?, completionHandler: (sucess: Bool, data: NSDictionary?, error: NSError?) -> Void){
        
        let initialUrl = toUrl
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: initialUrl)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = HTTPMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let HTTPBody = jsonBody{
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(HTTPBody, options: [])
            } catch _ as NSError {
                request.HTTPBody = nil
            }
        }
        
        let task = session.dataTaskWithRequest(request){
            data, response, downloadError in
            if let error = downloadError {
                completionHandler(sucess: false, data: nil, error: error)
                print("Error communicating with server via HTTP")
                print(error)
            }
            else{
                var jsonResult : AnyObject?
                do{
                    jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    completionHandler(sucess: true, data: jsonResult as? NSDictionary, error: nil)
                }catch{
                    completionHandler(sucess: false, data: nil, error: nil)
                }
            }
        }
        task.resume()
        
    }
    
    
}
