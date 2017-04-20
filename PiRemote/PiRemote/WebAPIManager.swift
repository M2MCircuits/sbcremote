//
//  WebAPIManager.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 3/5/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import Foundation

// Credit to Martin R at
// http://stackoverflow.com/questions/38023838/round-trip-swift-number-types-to-from-data
extension Data {

    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }

    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
}

class WebAPIManager {

    // MARK: Local Variables

    var api: APIManager!
    var baseApiUrl: String!
    var headerFields: [String: String]!

    convenience init() {
        let deviceIP = MainUser.sharedInstance.currentDevice?.apiData["deviceLastIP"]
        // WebIOPi default settings
        self.init(ipAddress: deviceIP, port: "8000", username: "webiopi", password: "raspberry")
    }

    init(ipAddress: String?, port: String?, username: String?, password: String?) {
        guard (ipAddress != nil) else { return }

        let loginString = String(format: "%@:%@", username!, password!)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        let portNumber = port!.isEmpty ? "" : ":\(port!)"

        api = APIManager()
        baseApiUrl = "https://" + ipAddress! + portNumber
        headerFields = ["Authorization" : "Basic " + base64LoginString]
    }

    // MARK: Local Functions

    func sendGetRequest(endpoint: String, completion: @escaping (_ data: Any?) -> Void) {
        guard baseApiUrl != nil else { fatalError("[ERROR] No baseApiUrl") }
        self.api.getRequest(url: baseApiUrl + endpoint, extraHeaderFields: headerFields) { data in
            completion(data != nil ? data : nil)
        }
    }

    func sendPostRequest(endpoint: String, completion: @escaping (_ data: Any?) -> Void) {
        guard baseApiUrl != nil else { fatalError("[ERROR] No baseApiUrl") }
        self.api.postRequest(url: baseApiUrl + endpoint, extraHeaderFields: headerFields, payload: nil) { data in
            completion(data != nil ? data : nil)
        }
    }

    // GET /GPIO/:gpioNumber/function
    func getFunction(gpioNumber: Int, completion: @escaping (_ function: String?) -> Void) {
        self.sendGetRequest(endpoint: "/GPIO/\(gpioNumber)/function") { data in
            completion(data != nil ? String(data: data as! Data, encoding: String.Encoding.utf8) : nil)
        }
    }

    // POST /GPIO/:gpioNumber/function/:(in or out or pwm)
    func setFunction(gpioNumber: Int, functionType: String, completion: @escaping (_ newFunction: String?) -> Void) {
        self.sendPostRequest(endpoint: "/GPIO/\(gpioNumber)/function/\(functionType)") { data in
            completion(data != nil ? String(data: data as! Data, encoding: String.Encoding.utf8) : nil)
        }
    }

    // GET /GPIO/:gpioNumber/value
    func getValue(gpioNumber: Int, completion: @escaping (_ value: Int?) -> Void) {
        self.sendGetRequest(endpoint: "/GPIO/\(gpioNumber)/value") { data in
            completion(data != nil ? (data as! Data).to(type: Int.self) : nil)
        }
    }

    // POST /GPIO/:gpioNumber/value/:(0 or 1)
    func setValue(gpioNumber: Int, value: Int, completion: @escaping (_ newValue: Int?) -> Void) {
        self.sendPostRequest(endpoint: "/GPIO/\(gpioNumber)/value/\(value)") { data in
            completion(data != nil ? (data as! Data).to(type: Int.self) : nil)
        }
    }

    // POST /GPIO/:gpioNumber/pulse/

    // POST /GPIO/:gpioNumber/sequence/:delay,:sequence

    // POST /GPIO/:gpioNumber/pulseRatio/:ratio

    // POST /GPIO/:gpioNumber/pulseAngle/:angle

    // POST /macros/:macro/:args

    // GET /*
    func getFullGPIOState(completion: @escaping (_ data: NSDictionary?) -> Void) {
        self.sendGetRequest(endpoint: "/*") { data in
            completion(data != nil ? data as? NSDictionary : nil)
        }
    }
}
