//
//  Pin.swift
//  PiRemote
//
//  Authors: Muhammad Martinez
//  Copyright (c) 2017 JLL Consulting. All rights reserved.
//

import Foundation

class Pin {

    // Types
    static let IGNORE = 0
    static let CONTROL = 1
    static let MONITOR = 2

    var _function: String = "IN"
    var function: String {
        get {
            return _function
        }
        set (newVal) {
            if type != Pin.IGNORE {
                type = newVal == "IN" ? Pin.MONITOR : Pin.CONTROL
                _function = newVal
            }
        }
    }

    var id: Int
    var name: String
    var statusWhenHigh: String
    var statusWhenLow: String
    var type: Int
    var value: Int

    init() {
        setupDefault()
    }

    init(id: Int, apiData: [String: AnyObject]) {
        setupDefault()

        self.id = id

        function = apiData["function"] as! String
        value = apiData["value"] as! Int

        // Monitor pins be default
        type = function == "IN" ? Pin.MONITOR : Pin.CONTROL
    }

    func setupDefault() {
        id = 0
        name = "label"
        statusWhenHigh = "On"
        statusWhenLow = "Off"
        type = Pin.IGNORE
        value = 0

        function = type == Pin.CONTROL ? "OUT" : "IN"
    }

    func isGPIO() -> Bool {
        // TODO: Add Pi Zero

        // not GPIO on Pi B Rev 1, Pi A/B Rev 2
        _ = [1, 2, 4, 6, 9, 14, 17, 20, 25] // piOneOrTwo
        // not GPIO on Pi B+
        let piThree = [1, 2, 4, 6, 9, 14, 17, 20, 25, 27, 28, 30, 34, 39]

        // TODO: Handle other models
        return !piThree.contains(id)
    }
}
