//
//  SysConstants.swift
//  PiRemote
//
//  Created by Victor Anyirah on 3/21/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

struct AppEngineConstants {
    static let BaseURL = "http://www.piremote-160105.appspot.com"
//    static let BaseURL = "http://localhost:8080"
//    static let secureBaseURL = "https://www.piremote-160105.appspot.com"
}

struct Theme {
    // https://material.io/guidelines/style/color.html#color-color-palette
    static let amber300 = UIColor(red: 0xff / 255, green: 0xd5 / 255, blue: 0x4f / 255, alpha: 1.0)
    static let amber500 = UIColor(red: 0xff / 255, green: 0xc1 / 255, blue: 0x07 / 255, alpha: 1.0)
    static let cyan300 = UIColor(red: 0x4d / 255, green: 0xd0 / 255, blue: 0xe1 / 255, alpha: 1.0)
    static let cyan500 = UIColor(red: 0x00 / 255, green: 0xbc / 255, blue: 0xd4 / 255, alpha: 1.0)
    static let grey300 = UIColor(red: 0xe0 / 255, green: 0xe0 / 255, blue: 0xe0 / 255, alpha: 1.0)
    static let grey500 = UIColor(red: 0x9e / 255, green: 0x9e / 255, blue: 0x9e / 255, alpha: 1.0)
    static let grey900 = UIColor(red: 0x21 / 255, green: 0x21 / 255, blue: 0x21 / 255, alpha: 1.0)
    static let lightGreen300 = UIColor(red: 0xae / 255, green: 0xd5 / 255, blue: 0x81 / 255, alpha: 1.0)
    static let lightGreen500 = UIColor(red: 0x8b / 255, green: 0xc3 / 255, blue: 0x4a / 255, alpha: 1.0)
    static let red300 = UIColor(red: 0xe5 / 255, green: 0x73 / 255, blue: 0x73 / 255, alpha: 1.0)
    static let red500 = UIColor(red: 0xf4 / 255, green: 0x43 / 255, blue: 0x36 / 255, alpha: 1.0)
}

struct DeviceTypes {
    static let rPi0 = "Rpi Zero"
    static let rPi1A = "RPi 1 Model A"
    static let rPi1Ap = "RPi 1 Model A+"
    static let rPi1B = "RPi 1 Model B"
    static let rPi1Bp = "RPi 1 Model B+"
    static let rPi2 = "RPi 2"
    static let rPi3 = "RPi 3"
}

// TODO: Add pinout images for remaining flavors of pi
struct PiFilePaths {
    static let rPi3 = "RaspberryPi_3B"
}

extension Notification.Name {
    static let apply = Notification.Name.init(rawValue: "USER_TOUCHED_APPLY")
    static let clear = Notification.Name.init(rawValue: "USER_TOUCHED_CLEAR")
    static let diagram = Notification.Name.init(rawValue: "USER_TOUCHED_DIAGRAM")
    static let login = Notification.Name.init(rawValue: "USER_TOUCHED_LOGIN")
    static let loginSuccess = Notification.Name.init(rawValue: "LOGIN_SUCCESS")
    static let save = Notification.Name.init(rawValue: "USER_TOUCHED_SAVE")
    static let touchPin = Notification.Name.init(rawValue: "USER_TOUCHED_PIN")
    static let updatePin = Notification.Name.init(rawValue: "UPDATE_PIN")
    static let updatePinInLayout = Notification.Name.init(rawValue: "UPDATE_PIN_LAYOUT")
}

enum PopoverTypes {
    case apply, clear, diagram, login, save
}

struct SegueTypes {
    static let idToDeviceDetails = "SHOW_DEVICE_DETAILS"
    static let idToDeviceSetup = "SHOW_DEVICE_SETUP"
    static let idToDevicesTable = "SHOW_DEVICES"
    static let idToPinSettings = "SHOW_PIN_SETTINGS"
    static let idToPopoverApply = "POPOVER_APPLY"
    static let idToPopoverClear = "POPOVER_CLEAR"
    static let idToPopoverDiagram = "POPOVER_DIAGRAM"
    static let idToPopoverLogin = "POPOVER_LOGIN"
    static let idToPopoverSave = "POPOVER_SAVE"
    static let idToWebLogin = "SHOW_WEBIOPI_LOGIN"
}

struct DeviceAPIType{
    static let deviceAddress = "deviceAddress"
    static let deviceAlias = "deviceAlias"
    
}


struct PinHeader {
    static let modelB = [
        1: "3V3", 2: "5V", 4: "5V", 3: "GPIO 2", 5: "GPIO 3", 6: "Ground", 7: "GPIO 4", 8: "GPIO 14",
        9: "Ground", 10: "GPIO 15", 11: "GPIO 17", 12: "GPIO 18", 13: "GPIO 27", 14: "Ground", 15: "GPIO 22",
        16: "GPIO 23", 17: "3V3", 18: "GPIO 24", 19: "GPIO 10", 20: "Ground", 21: "GPIO 9", 22: "GPIO 25",
        23: "GPIO 11", 24: "GPIO 8", 25: "Ground", 26: "GPIO 7"
    ]
    static let modelBPlus = [
        27: "ID_SD", 28: "ID_SC", 29: "GPIO 5", 31: "GPIO 6", 32: "GPIO 12", 33: "GPIO 13", 35: "GPIO 19",
        36: "GPIO 16", 37: "GPIO 26", 38: "GPIO 20", 40: "GPIO 21", 30: "Ground", 34: "Ground", 39: "Ground"
    ]
}


