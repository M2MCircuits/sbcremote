//
//  DeviceSetupViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 2/26/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

// TODO: Handle different pi models. Currently supports Pi 3
class DeviceSetupViewController: UIViewController, UIPopoverPresentationControllerDelegate, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!

    // MARK: Local Variables
    var currentImageView: UIImageView!
    var currentPinSetup: [Pin]!
    var popoverView: UIViewController!

    let pickerOptions = [
        DeviceTypes.rPi3
    ].self

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Check if we should load from layout
        currentPinSetup = initPinSetup()

        // Setting up navigation bar
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(DeviceSetupViewController.onLeave))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(DeviceSetupViewController.onSetDeviceSettings))

        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.title = "Device Setup"

        // Adding buttons for pins
        buildScrollView()

        // Adding event listeners for notifications from popovers
        NotificationCenter.default
            .addObserver(self, selector: #selector(self.handleApplyLayout), name: Notification.Name.apply, object: nil)
        NotificationCenter.default
            .addObserver(self, selector: #selector(self.handleClearLayout), name: Notification.Name.clear, object: nil)
        NotificationCenter.default
            .addObserver(self, selector: #selector(self.handleSaveLayout), name: Notification.Name.save, object: nil)
        NotificationCenter.default
            .addObserver(self, selector: #selector(self.handleValidLogin), name: Notification.Name.loginSuccess, object: nil)
        NotificationCenter.default
            .addObserver(self, selector: #selector(self.handleUpdatePin), name: Notification.Name.updatePin, object: nil)
    }

    override func viewDidLayoutSubviews() {
        scrollView!.maximumZoomScale = 2.0
        scrollView!.minimumZoomScale = 0.5
        scrollView!.setZoomScale(1.0, animated: true)
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
            contentSize = CGSize(width: 150, height: 250)
            sourceRect = CGRect(origin: CGPoint(x: 0, y: 0), size: destination.view.bounds.size)
            (destination as! PinSettingsViewController).pin = sender as! Pin
        default: break
        }

        popoverView = PopoverViewController.buildPopover(
                source: self, content: destination, contentSize: contentSize, sourceRect: sourceRect)
    }

    // MARK: UIScrollViewDelegate Functions

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return currentImageView
    }

    // MARK: UIPopoverPresentationControllerDelegate Functions

    // Prevents popover from changing style based on the iOS device
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    // MARK: Local Functions

    func buildScrollView() {
        let btnWidth = 40
        let btnHeight = 40
        let midX = Int(scrollView.bounds.midX)

        scrollView.autoresizingMask = UIViewAutoresizing.flexibleHeight
        scrollView.contentSize = CGSize(width: Int(scrollView.frame.width * 1.5), height: btnHeight * 40)
        scrollView.delegate = self

        // Position buttons with respect to image
        var isEven: Bool
        var x, y: Int

        for i in 1...40 {
            isEven = i % 2 == 0
            x = isEven ? midX + 2 : midX - btnWidth - 2
            y = (btnHeight + 8) * ((i - 1) / 2)

            let pinButton = UIButton(type: UIButtonType.roundedRect) as UIButton

            pinButton.addTarget(self, action: #selector(DeviceSetupViewController.onTouchTap(sender:)), for: .touchUpInside)
            pinButton.backgroundColor = UIColor.purple
            pinButton.frame = CGRect(x: x, y: y, width: btnWidth, height: btnHeight)
            pinButton.setTitle("\(i)", for: UIControlState.normal)
            pinButton.setTitleColor(UIColor.yellow, for: UIControlState.normal)
            pinButton.tag = i

            scrollView.addSubview(pinButton)
        }
    }

    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = paths[0] as String
        return documentDirectory
    }

    func handleApplyLayout(notification: Notification) {
        let fileName = notification.userInfo?["layoutName"] as! String
        let filePath = documentsDirectory().appending("/\(fileName)")
        let layout = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as! PinLayout

        currentPinSetup = layout.defaultSetup

        refreshPinButtons()
        popoverView.dismiss(animated: true, completion: nil)
    }

    func handleClearLayout() {
        currentPinSetup = initPinSetup()
        refreshPinButtons()
        popoverView.dismiss(animated: true, completion: nil)
    }

    func handleSaveLayout(notification: Notification) {
        let fileName = notification.userInfo?["text"] as! String
        let filePath = documentsDirectory().appending("/\(fileName)")
        let layout = PinLayout(name: fileName, defaultSetup: currentPinSetup) as PinLayout

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

    func handleUpdatePin(notification: Notification) {
        let userInfo = notification.userInfo as! [String:String]
        let i = Int(userInfo["id"]!)! - 1
        let name = userInfo["name"]
        let type = userInfo["type"]

        currentPinSetup[i].name = name!

        switch type! {
        case "control":
            currentPinSetup[i].type = .control
        case "ignore":
            currentPinSetup[i].type = .ignore
        case "monitor":
            currentPinSetup[i].type = .monitor
        default: break
        }

        refreshPinButtons()
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

    func loadLayouts() {
        var layouts = NSKeyedUnarchiver.unarchiveObject(withFile: documentsDirectory())
        guard layouts != nil else {
            return
        }
    }

    func onLeave(sender: UIButton!) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    func onSetDeviceSettings(sender: UIButton!) {
        // TODO: Implement saving the layout
        onLeave(sender: sender!)
    }

    func onTouchTap(sender: UIButton!) {
        let i = sender.tag
        let offset = CGPoint(x: i % 2 == 0 ? -80 : 80,
                             y: ((i - 1) / 2) * 25)

        // Open popover with selected pin data
        self.performSegue(withIdentifier: SegueTypes.idToPinSettings, sender: currentPinSetup[i-1])

        // Scroll over to pin
        scrollToPoint(point: offset)
    }

    func refreshPinButtons() {
        for child in scrollView.subviews {
            guard child is UIButton else { break }

            let pinButton = child as! UIButton
            let i = pinButton.tag

            switch currentPinSetup[i - 1].type {
            case .ignore:
                pinButton.backgroundColor = UIColor.gray
            case .monitor:
                pinButton.backgroundColor = UIColor.blue
            case .control:
                pinButton.backgroundColor = UIColor.orange
            }
        }
    }

    func scrollToPoint(point: CGPoint) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.scrollView.contentOffset = point
            }, completion: nil)
        }
    }
}
