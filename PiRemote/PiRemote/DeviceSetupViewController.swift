//  DeviceSetupViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 2/26/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

// TODO: Handle different pi models. Currently supports Pi 3
@available(iOS 9.0, *)
class DeviceSetupViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var layoutNameLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!

    // MARK: Local Variables

    var popoverView: UIViewController!
    var scrollView: PinSetupScrollView!
    var webAPI: WebAPIManager!

    let pickerOptions = [
        DeviceTypes.rPi3
        ].self

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up navigation bar
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(DeviceSetupViewController.onLeave))
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(DeviceSetupViewController.onToggleEditDeviceSettings))

        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = editButton

        self.scrollView = stackView.arrangedSubviews[0] as! PinSetupScrollView
        self.scrollView.setPinData(pins: (MainUser.sharedInstance.currentDevice?.layout.defaultSetup)!)

        self.stackView.arrangedSubviews[1].isHidden = true
        self.stackView.arrangedSubviews[3].isHidden = true

        // Adding event listeners for notifications from popovers
        NotificationCenter.default
            .addObserver(self, selector: #selector(self.handleApplyLayout), name: Notification.Name.apply, object: nil)
        NotificationCenter.default
            .addObserver(self, selector: #selector(self.handleClearLayout), name: Notification.Name.clear, object: nil)
        NotificationCenter.default
            .addObserver(self, selector: #selector(self.handleSaveLayout), name: Notification.Name.save, object: nil)
        NotificationCenter.default
            .addObserver(self, selector: #selector(self.handleUpdatePin), name: Notification.Name.updatePinInLayout, object: nil)
        NotificationCenter.default
            .addObserver(self, selector: #selector(self.handleTouchPin), name: Notification.Name.touchPin, object: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        var contentSize: CGSize!
        var sourceRect: CGRect!

        switch segue.identifier! {
        case SegueTypes.idToPopoverApply:
            contentSize = CGSize(width: 360, height: 400)
        case SegueTypes.idToPopoverSave:
            contentSize = CGSize(width: 360, height: 200)
        case SegueTypes.idToPopoverClear:
            contentSize = CGSize(width: 360, height: 200)
        case SegueTypes.idToPopoverDiagram:
            contentSize = CGSize(width: 360, height: 700)
        case SegueTypes.idToPinSettings:
            let pin = sender as! Pin
            contentSize = CGSize(width: 150, height: 320)
            sourceRect = CGRect(origin: CGPoint(x: 0, y: 0), size: destination.view.bounds.size)
            (destination as! EditPinViewController).pin = pin
            (destination as! EditPinViewController).webAPI = webAPI
            destination.isEditing = self.navigationItem.rightBarButtonItem?.title == "Done"
        default: break
        }

        // Saving popover view to dismiss it later
        popoverView = PopoverViewController.buildPopover(
            source: self, content: destination, contentSize: contentSize, sourceRect: sourceRect)
    }

    // MARK: UIPopoverPresentationControllerDelegate Functions

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Prevents popover from changing style based on the iOS device
        return UIModalPresentationStyle.none
    }

    // MARK: Local Functions

    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = paths[0] as String
        return documentDirectory
    }

    func handleApplyLayout(notification: Notification) {
        let fileName = notification.userInfo?["layoutName"] as! String
        let filePath = documentsDirectory().appending("/\(fileName)")
        let layout = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as! PinLayout

        MainUser.sharedInstance.currentDevice?.layout = layout

        scrollView.setPinData(pins: layout.defaultSetup)
        popoverView.dismiss(animated: false)
    }

    func handleClearLayout() {
        var layout = (MainUser.sharedInstance.currentDevice?.layout)!
        layout = PinLayout(name: "custom", defaultSetup: initPinSetup())
        scrollView.setPinData(pins: layout.defaultSetup)
        popoverView.dismiss(animated: false)
    }

    func handleSaveLayout(notification: Notification) {
        let defaultSetup = (MainUser.sharedInstance.currentDevice?.layout.defaultSetup)!
        let fileName = notification.userInfo?["text"] as! String
        let layout = PinLayout(name: fileName, defaultSetup: defaultSetup) as PinLayout

        save(layout: layout, as: fileName)

        // Notifiying user
        SharedSnackbar.show(parent: self.stackView, type: .check, message: "Saved as \(fileName)")
        popoverView.dismiss(animated: false)
    }

    func handleTouchPin(notification: Notification) {
        let i = notification.userInfo?["tag"] as! Int
        let pin = MainUser.sharedInstance.currentDevice?.layout.defaultSetup[i-1]

        // Preventing attempt to edit non-GPIO pins
        guard pin!.isGPIO() else {
            SharedSnackbar.show(parent: (view)!, type: .warn, message: "You can only update GPIO pins")
            return
        }

        // Opening popover with selected pin data
        self.performSegue(withIdentifier: SegueTypes.idToPinSettings, sender: pin)
    }

    func handleUpdatePin(notification: Notification) {
        // Preventing changes outside of editing mode
        guard self.isEditing else { return }

        let layout = (MainUser.sharedInstance.currentDevice?.layout)!
        let userInfo = notification.userInfo as! [String:Any]
        let i = (userInfo["id"] as! Int) - 1

        layout.defaultSetup[i].name = userInfo["name"] as! String
        layout.defaultSetup[i].type = userInfo["type"] as! Pin.Types
        layout.defaultSetup[i].value = userInfo["value"] as! Int

//        DispatchQueue.main.async {
            self.scrollView.setPinData(pins: layout.defaultSetup)
            self.popoverView.dismiss(animated: false)
//        }
    }


    func initSavedLayoutNames() -> [String]! {
        if let data = UserDefaults.standard.object(forKey: "layoutNames") as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as! [String]!
        }
        return []
    }

    func initPinSetup() -> [Pin] {
        var pins = [Pin]()
        for i in 1...26 { pins.append(Pin(id: i)) }
        return pins
    }

    func onLeave(sender: UIBarButtonItem!) {
        let layout = (MainUser.sharedInstance.currentDevice?.layout)!
        save(layout: layout, as: layout.name)

        if self.isEditing {
            self.isEditing = false
            self.updateNavBarItems()
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                    self.stackView.arrangedSubviews[1].isHidden = true
                })
            }
        } else {
            _ = self.navigationController?.popViewController(animated: false)
        }
    }

    func onToggleEditDeviceSettings(sender: UIBarButtonItem!) {
        isEditing = !isEditing

        self.updateNavBarItems()
        let layout = (MainUser.sharedInstance.currentDevice?.layout)!

        if (!isEditing) {
            save(layout: layout, as: layout.name)
        }

        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                self.stackView.arrangedSubviews[1].isHidden = !self.isEditing
            })
        }
    }

    @IBAction func onToggleMoreSettings(_ sender: UIButton) {
        let isCurrentlyHidden = sender.titleLabel!.text!.contains("Show") as Bool
        let newTitle = isCurrentlyHidden ? "Hide More Settings" : "Show More Settings"

        layoutNameLabel!.text = MainUser.sharedInstance.currentDevice?.layout.name

        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                (self.stackView.arrangedSubviews[2] as! UIButton).titleLabel!.text = newTitle
                self.stackView.arrangedSubviews[3].isHidden = !isCurrentlyHidden
            })
        }
    }

    func save(layout: PinLayout, as name: String) {
        // TODO: Warn users when we are overriding an existing layout
        let filePath = documentsDirectory().appending("/\(name)")

        // Archiving layout data
        NSKeyedArchiver.archiveRootObject(layout, toFile: filePath)

        // Saving layout name to user defaults
        var savedLayoutNames: [String]

        if let data = UserDefaults.standard.object(forKey: "layoutNames") as? Data {
            savedLayoutNames = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String]!
        } else {
            savedLayoutNames = []
        }

        if !savedLayoutNames.contains(name) {
            savedLayoutNames.append(name)
        }

        let data = NSKeyedArchiver.archivedData(withRootObject: savedLayoutNames)
        UserDefaults.standard.set(data, forKey: "layoutNames")
    }

    func updateNavBarItems () {
        var leftBtnTitle: String = "Error"
        var rightBtnTitle: String = "Error"

        if self.isEditing {
            leftBtnTitle = "Cancel"
            rightBtnTitle = "Done"
        } else {
            leftBtnTitle = "Back"
            rightBtnTitle = "Edit"
        }

        // Updating nav bar
        self.navigationItem.leftBarButtonItem?.title = leftBtnTitle
        self.navigationItem.rightBarButtonItem?.title = rightBtnTitle
    }
}
