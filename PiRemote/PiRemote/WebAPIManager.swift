//
//  WebAPIManager.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 3/5/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import Foundation

class WebAPIManager {

    // Local Variables
    var api: APIManager!
    var baseApiUrl: String!
    var webHeaderFields: [String: String]!
    var webPort: String!

    let errorResponse = "No device selected to use WebAPIManager"

    convenience init() {
        // Connects to pi via its external ip address. If the pi is connected to a router, it must be exposed using Port
        // Forwarding. When testing in the simulator, be sure to do so on different networks. It may not work on certain
        // public networks possibly due to their added security.
        //
        // Details: http://superuser.com/questions/284051/what-is-port-forwarding-and-what-is-it-used-for
        let deviceIP = MainUser.sharedInstance.currentDevice?.apiData["deviceLastIP"]

        // WebIOPi default settings
        self.init(ipAddress: deviceIP, port: "8000", username: "webiopi", password: "raspberry")
    }

    init(ipAddress: String?, port: String?, username: String?, password: String?) {
        guard (ipAddress != nil) else {
            print("ERROR: Cannot find device because ip address is null")
            return
        }

        let loginString = String(format: "%@:%@", username!, password!)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()

        api = APIManager()
        baseApiUrl = "https://" + ipAddress! + (port!.isEmpty ? "" : ":" + port!)
        webHeaderFields = ["Authorization" : "Basic " + base64LoginString]
    }

    // GET /GPIO/:gpioNumber/function
    func getFunction(gpioNumber: Int, callback: @escaping (_ function: String?) -> Void) {
        guard baseApiUrl != nil else {
            return
        }

        let endpointURL = "/GPIO/\(gpioNumber)/function"
        self.api.getRequest(url: baseApiUrl + endpointURL, extraHeaderFields: webHeaderFields, completion: {
            data in
                guard data != nil else{
                    print(self.errorResponse)
                    callback(nil)
                    return
                }
                callback(String(data: data as! Data, encoding: String.Encoding.utf8))
        })
    }

    // POST /GPIO/:gpioNumber/function/:(in or out or pwm)
    func setFunction(gpioNumber: Int, functionType: String, callback: @escaping (_ newFunction: String?) -> Void) {
        guard baseApiUrl != nil else {
            return
        }

        let endpointURL = "/GPIO/\(gpioNumber)/function/\(functionType)"
        self.api.postRequest(url: baseApiUrl + endpointURL, extraHeaderFields: webHeaderFields, payload: nil, completion: {
            data in
                guard data != nil else{
                    print(self.errorResponse)
                    callback(nil)
                    return
                }
                callback(String(data: data as! Data, encoding: String.Encoding.utf8))
        })
    }

    // GET /GPIO/:gpioNumber/value
    func getValue(gpioNumber: Int, callback: @escaping (_ value: Int?) -> Void) {
        guard baseApiUrl != nil else {
            return
        }

        let endpointURL = "/GPIO/\(gpioNumber)/value"
        self.api.getRequest(url: baseApiUrl + endpointURL, extraHeaderFields: webHeaderFields, completion: {
            data in
                guard data != nil else{
                    print(self.errorResponse)
                    callback(nil)
                    return
                }
                // TODO: Hasn't been tested yet. If data is being returned as nil you can either decode it directly as 
                // Int, or as String then cast to Int
                callback(data as! Int?)
        })
    }

    // POST /GPIO/:gpioNumber/value/:(0 or 1)
    func setValue(gpioNumber: Int, value: Int, callback: @escaping (_ newValue: Int?) -> Void) {
        guard baseApiUrl != nil else {
            return
        }

        let endpointURL = "/GPIO/\(gpioNumber)/value/\(value)"
        self.api.postRequest(url: baseApiUrl + endpointURL, extraHeaderFields: webHeaderFields, payload: nil, completion: {
            data in
                guard data != nil else{
                    print(self.errorResponse)
                    callback(nil)
                    return
                }
                // TODO: Hasn't been tested yet. If data is being returned as nil you can either decode it directly as
                // Int, or as String then cast to Int
                callback(data as! Int?)
        })
    }

    // POST /GPIO/:gpioNumber/pulse/

    // POST /GPIO/:gpioNumber/sequence/:delay,:sequence

    // POST /GPIO/:gpioNumber/pulseRatio/:ratio

    // POST /GPIO/:gpioNumber/pulseAngle/:angle

    // POST /macros/:macro/:args

    // GET /*
    func getFullGPIOState(callback: @escaping (_ data: NSDictionary?) -> Void) {
        guard baseApiUrl != nil else {
            return
        }

        let endpointURL = "/*"
        self.api.getRequest(url: baseApiUrl + endpointURL, extraHeaderFields: webHeaderFields, completion: {
            data in
                guard data != nil else{
                    print(self.errorResponse)
                    callback(nil)
                    return
                }

                callback(data as? NSDictionary)
        })
    }
}
