//
//  Pin.swift
//  PiRemote
//
//  Authors: Muhammad Martinez
//  Copyright (c) 2017 JLL Consulting. All rights reserved.
//

import Foundation

class Pin: NSObject, NSCoding {

    enum Types: Int {
        case ignore = 0
        case control = 1
        case monitor = 2
    }

    // TODO: Values like "ALT0", "ALT3", etc. are being saved as "IN". Should we be doing this?
    var _function: String = "IN"
    var function: String {
        get {
            return _function
        }
        set (newVal) {
            switch newVal {
            case "IN": type = .monitor
            case "OUT": type = .control
            default: type = .ignore
            }
            _function = newVal
        }
    }

    var id: Int = 0
    var name: String = ""
    var statusWhenHigh: String = "On"
    var statusWhenLow: String = "Off"
    var type: Types = .ignore
    var value: Int = 0

    init(id: Int) {
        super.init()
        self.id = id
    }

    init(id: Int, apiData: [String: AnyObject]) {
        super.init()
        self.id = id
        self.function = apiData["function"] as! String
        self.type = self.function == "IN" ? .monitor : .control
        self.value = apiData["value"] as! Int
    }


    init(id: Int, name: String, function: String, value: Int,
         type: Types = .ignore, statusWhenHigh: String = "On", statusWhenLow: String = "Off") {
        super.init()
        self.function = function
        self.id = id
        self.name = name
        self.statusWhenHigh = statusWhenHigh
        self.statusWhenLow = statusWhenLow
        self.type = type
        self.value = value
    }

    // MARK: NSCoding

    required init(coder decoder: NSCoder) {
        super.init()
        self.function = decoder.decodeObject(forKey: "function") as! String
        self.id = decoder.decodeInteger(forKey: "id")
        self.name = decoder.decodeObject(forKey: "name") as! String
        self.statusWhenHigh = decoder.decodeObject(forKey: "statusWhenHigh") as! String
        self.statusWhenLow = decoder.decodeObject(forKey: "statusWhenLow") as! String
        self.type = Types.init(rawValue: decoder.decodeInteger(forKey: "type"))!
        self.value = decoder.decodeInteger(forKey: "value")
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.function, forKey: "function")
        coder.encode(self.id, forKey: "id")
        coder.encode(self.name, forKey: "name")
        coder.encode(self.statusWhenHigh, forKey: "statusWhenHigh")
        coder.encode(self.statusWhenLow, forKey: "statusWhenLow")
        coder.encode(self.type.rawValue, forKey: "type")
        coder.encode(self.value, forKey: "value")
    }


    // MARK: Local Functions


    func isGPIO() -> Bool {
        // TODO: Add Pi Zero

        // not GPIO on Pi B Rev 1, Pi A/B Rev 2
        _ = [1, 2, 4, 6, 9, 14, 17, 20, 25] // piOneOrTwo
        // not GPIO on Pi B+
        let piThree = [1, 2, 4, 6, 9, 14, 17, 20, 25, 27, 28, 30, 34, 39]

        // TODO: Handle other models
        return !piThree.contains(id)
    }

    func isEven() -> Bool {
        return id % 2 == 0
    }
}
