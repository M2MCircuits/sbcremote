//
//  PinLayout.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 3/29/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import Foundation

class PinLayout: NSObject, NSCoding {

    // TODO: Handle based on model type. Assumes B+
    var pins: [Pin]
    var name: String

    init(name: String, pins: [Pin]) {
        self.pins = pins
        self.name = name
        super.init()
    }

    // MARK: NSCoding
    
    required init(coder decoder: NSCoder) {
        self.pins = decoder.decodeObject(forKey: "pins") as! [Pin]
        self.name = decoder.decodeObject(forKey: "name") as! String
    }

    func encode(with coder: NSCoder) {
        coder.encode(pins, forKey: "pins")
        coder.encode(name, forKey: "name")
    }
}
