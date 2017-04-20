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
    var pinLayout: PinLayout!
    var popoverView: UIViewController!
    var scrollView: PinSetupScrollView!

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

        guard pinLayout != nil else { fatalError("[ERROR] No pin layout provided") }

        // Setting up navigation bar
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(DeviceSetupViewController.onLeave))
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(DeviceSetupViewController.onToggleEditDeviceSettings))

        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = editButton
        self.navigationItem.title = "Device Setup"

        self.scrollView = stackView.arrangedSubviews[0] as! PinSetupScrollView
        self.scrollView.setPinData(pins: pinLayout.defaultSetup)

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
            .addObserver(self, selector: #selector(self.handleUpdatePin), name: Notification.Name.updatePin, object: nil)
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

        pinLayout = layout

        scrollView.setPinData(pins: pinLayout.defaultSetup)
        popoverView.dismiss(animated: true, completion: nil)
    }

    func handleClearLayout() {
        pinLayout = PinLayout(name: "custom", defaultSetup: initPinSetup())
        scrollView.setPinData(pins: pinLayout.defaultSetup)
        popoverView.dismiss(animated: true, completion: nil)
    }

    func handleSaveLayout(notification: Notification) {
        let fileName = notification.userInfo?["text"] as! String
        let filePath = documentsDirectory().appending("/\(fileName)")
        let layout = PinLayout(name: fileName, defaultSetup: pinLayout.defaultSetup) as PinLayout

        // Saving layout data
        NSKeyedArchiver.archiveRootObject(layout, toFile: filePath)

        // Recording layout name to user defaults
        var savedLayoutNames: [String]

        if let data = UserDefaults.standard.object(forKey: "layoutNames") as? Data {
            savedLayoutNames = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String]!
        } else {
            savedLayoutNames = []
        }

        savedLayoutNames.append(fileName)
        let data = NSKeyedArchiver.archivedData(withRootObject: savedLayoutNames)
        UserDefaults.standard.set(data, forKey: "layoutNames")

        // TODO: Show success snackbar
        print("Saved as \(fileName)")
        popoverView.dismiss(animated: true, completion: nil)
    }

    func handleTouchPin(notification: Notification) {
        let i = notification.userInfo?["tag"] as! Int
        // Open popover with selected pin data
        self.performSegue(withIdentifier: SegueTypes.idToPinSettings, sender: pinLayout.defaultSetup[i-1])
    }

    func handleUpdatePin(notification: Notification) {
        // Checking if we're in editing mode
        guard self.navigationItem.rightBarButtonItem?.title == "Done" else {
            return
        }

        let userInfo = notification.userInfo as! [String:String]
        let i = Int(userInfo["id"]!)! - 1

        var type: Pin.Types
        switch userInfo["type"]! {
        case "control": type = .control
        case "ignore": type = .ignore
        case "monitor": type = .monitor
        default: type = .ignore
        }

        pinLayout.defaultSetup[i].name = userInfo["name"]!
        pinLayout.defaultSetup[i].type = type
        pinLayout.defaultSetup[i].value = userInfo["value"]! == "true" ? 1 : 0

        scrollView.setPinData(pins: pinLayout.defaultSetup)
    }

    func handleValidLogin() {
        print("LOGIN IS VALID")
    }

    func initSavedLayoutNames() -> [String]! {
        if let data = UserDefaults.standard.object(forKey: "layoutNames") as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as! [String]!
        }
        return []
    }

    func initPinSetup() -> [Pin] {
        var pins = [Pin]()
        for i in 1...40 { pins.append(Pin(id: i)) }
        return pins
    }


    func onLeave(sender: UIBarButtonItem!) {
        switch sender.title! {
        case "Cancel":
            // Updating nav bar
            self.navigationItem.leftBarButtonItem?.title = "Back"
            self.navigationItem.rightBarButtonItem?.title = "Edit"

            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                    self.stackView.arrangedSubviews[1].isHidden = true
                }, completion: nil)
            }
        case "Back":
            _ = self.navigationController?.popViewController(animated: true)
        default: break
        }
    }

    func onToggleEditDeviceSettings(sender: UIBarButtonItem!) {
        var leftBtnTitle: String = "Error"
        var rightBtnTitle: String = "Error"
        var shouldHideToolbar: Bool = false

        switch sender.title! {
        case "Edit":
            leftBtnTitle = "Cancel"
            rightBtnTitle = "Done"
            shouldHideToolbar = false
        case "Done":
            leftBtnTitle = "Back"
            rightBtnTitle = "Edit"
            shouldHideToolbar = true
            // TODO: Implement saving the layout
        default: break
        }

        // Updating nav bar
        self.navigationItem.leftBarButtonItem?.title = leftBtnTitle
        self.navigationItem.rightBarButtonItem?.title = rightBtnTitle

        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                self.stackView.arrangedSubviews[1].isHidden = shouldHideToolbar
            }, completion: nil)
        }
    }

    @IBAction func onToggleMoreSettings(_ sender: UIButton) {
        let isCurrentlyHidden = sender.titleLabel!.text!.contains("Show") as Bool
        let newTitle = isCurrentlyHidden ? "Hide More Settings" : "Show More Settings"

        layoutNameLabel!.text = pinLayout.name

        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                (self.stackView.arrangedSubviews[2] as! UIButton).titleLabel!.text = newTitle
                self.stackView.arrangedSubviews[3].isHidden = !isCurrentlyHidden
            }, completion: nil)
        }
    }
}
