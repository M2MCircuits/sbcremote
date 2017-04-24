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
        self.id = id + 1
        self.function = apiData["function"] as! String
        self.value = apiData["value"] as! Int

        // TODO: Handle other pi versions
        if self.id <= 26 {
            self.name = PinHeader.modelB[self.id]!
        } else if self.id <= 40 {
            self.name = PinHeader.modelBPlus[self.id]!
        }

        if !isGPIO() {
            self.type = .ignore
        } else {
            self.type = self.function == "IN" ? .monitor : .control
        }
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
        // TODO: Handle other versions of pi
        if id <= 26 {
            return PinHeader.modelB[id]!.contains("GPIO")
        } else if id <= 40 {
            return PinHeader.modelBPlus[id]!.contains("GPIO")
        } else {
            return false
        }
    }

    func isEven() -> Bool {
        return id % 2 == 0
    }
}
