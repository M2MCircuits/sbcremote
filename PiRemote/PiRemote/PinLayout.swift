//
//  PinLayout.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 3/29/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import Foundation

class PinLayout {

    // TODO: Handle based on model type. Assumes B+
    var defaultSetup: [Pin]
    var name: String

    init() {
        defaultSetup = [Pin]()
        name = "No Name"
    }
}
