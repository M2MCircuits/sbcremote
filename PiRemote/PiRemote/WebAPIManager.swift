//
//  WebAPIManager.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 3/5/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import Foundation

class WebAPIManager {

    var api: APIManager!
    var baseApiUrl: String!
    var base64LoginString: String!
    var deviceIP: String!
    var webHeaderFields: [String: String]

    let errorResponse = "No device selected to use WebAPIManager"

    init() {
        api = APIManager()
        deviceIP = "192.168.2.9" // MainUser.sharedInstance.currentDevice[]
        // TODO: Allow different port numbers (8000 is default)
        baseApiUrl = "http://" + deviceIP + ":8000"

        // TODO: Use user inputted login
        let loginString = String(format: "%@:%@", "webiopi", "raspberry")
        let loginData = loginString.data(using: String.Encoding.utf8)!
        self.base64LoginString = loginData.base64EncodedString()
        self.webHeaderFields = ["Authorization" : "Basic " + self.base64LoginString!]
    }

    // GET /GPIO/:gpioNumber/function
    func getFunction(gpioNumber: Int, callback: @escaping (_ data: NSDictionary?) -> Void) {
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

                callback(data!)
        })
    }

    // POST /GPIO/:gpioNumber/function/:(in or out or pwm)
    func setFunction(gpioNumber: Int, functionType: String, callback: @escaping (_ data: NSDictionary?) -> Void) {
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

                callback(data!)
        })
    }

    // GET /GPIO/:gpioNumber/value
    func getValue(gpioNumber: Int, callback: @escaping (_ data: NSDictionary?) -> Void) {
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

                callback(data!)
        })
    }

    // POST /GPIO/:gpioNumber/value/:(0 or 1)
    func setValue(gpioNumber: Int, newValue: Int, callback: @escaping (_ data: NSDictionary?) -> Void) {
        guard baseApiUrl != nil else {
            return
        }

        let endpointURL = "/GPIO/\(gpioNumber)/value/\(newValue)"
        self.api.postRequest(url: baseApiUrl + endpointURL, extraHeaderFields: webHeaderFields, payload: nil, completion: {
            data in
                guard data != nil else{
                    print(self.errorResponse)
                    callback(nil)
                    return
                }

                callback(data!)
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

            callback(data!)
        })
    }
}
