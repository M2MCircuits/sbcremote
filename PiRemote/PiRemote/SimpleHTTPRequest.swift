//
//  SimpleHTTPRequest.swift
//  PiRemote
//
//  Created by Victor Anyirah on 2/3/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import Foundation


class SimpleHTTPRequest : NSObject {
    
    /**
     Base request function for communicating with sever via HTTP. Only for simple, non-media related transmission
     
     - parameter url: (String), HTTPMethod(String), jsonBody([String: AnyObject], completionhandler
     - returns: success, error, dictionary optional with json information via callback.
     */
    func simpleAPIRequest(
        toUrl: String,
        HTTPMethod: String,
        jsonBody: [String: AnyObject]?,
        extraHeaderFields: [String: String]?,
        completionHandler: @escaping (_ sucess: Bool, _ data: Any?, _ error: Error?) -> Void) {
        
        //Creates URL Session
        let session = URLSession.shared
        
        //If the url is not valid, we fail and return.
        guard let url = URL(string: toUrl) else {
            completionHandler(false, nil, nil)
            return
        }
        
        //Creates request with fields
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod

        if extraHeaderFields != nil {
            for (fieldName, fieldValue) in extraHeaderFields! {
                request.setValue(fieldValue, forHTTPHeaderField: fieldName)
            }
        }
        
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

            //Connectivity issues
            if let error = downloadError {
                completionHandler(false, nil, downloadError)
                print("Error communicating with server via HTTP")
                print(error)
            }

            // Something went really wrong. Possibly server-side.
            guard (response as? HTTPURLResponse) != nil else {
                completionHandler(false, nil, nil)
                return
            }

            // Status 200 = OK
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                completionHandler(false, nil, nil)
                return
            }

            do {
                guard let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary else {
                    print("Failed to cast json result to dictionary")
                    completionHandler(false, nil, nil)
                    return
                }
                completionHandler(true, jsonResult, nil)
            } catch {
                completionHandler(true, data!, nil)
            }
        }
        task.resume()
    }
}
