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
    var defaultSetup: [Pin]
    var name: String

    init(name: String, defaultSetup: [Pin]) {
        self.defaultSetup = defaultSetup
        self.name = name
        super.init()
    }

    // MARK: NSCoding
    
    required init(coder decoder: NSCoder) {
        self.defaultSetup = decoder.decodeObject(forKey: "defaultSetup") as! [Pin]
        self.name = decoder.decodeObject(forKey: "name") as! String
    }

    func encode(with coder: NSCoder) {
        coder.encode(defaultSetup, forKey: "defaultSetup")
        coder.encode(name, forKey: "name")
    }
}
