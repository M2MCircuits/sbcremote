//
//  EditPinViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 4/9/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

class EditPinViewController: UIViewController {

    @IBOutlet weak var controlButton: UIButton!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var ignoreButton: UIButton!
    @IBOutlet weak var monitorButton: UIButton!
    @IBOutlet weak var nameBox: UITextField!
    @IBOutlet weak var onOffLabel: UILabel!
    @IBOutlet weak var onOffSwitch: UISwitch!

    // MARK: Local Variables

    var activityIndicator: UIActivityIndicatorView!
    var pin: Pin!
    var webAPI: WebAPIManager!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Styling based on initial pin data
        if !pin!.name.isEmpty {
            nameBox.text = pin!.name
        }

        header.text = pin!.boardName
        onOffLabel.text = pin!.value == 1 ? "On" : "Off"
        onOffSwitch.isOn = pin!.value == 1
        onOffSwitch.isEnabled = isEditing && pin!.type == .control

        switch pin!.type {
        case .control:
            controlButton.backgroundColor = pin!.value == 1 ? Theme.lightGreen500 : Theme.amber500
            controlButton.setTitleColor(UIColor.white, for: .normal)
        case .monitor:
            monitorButton.backgroundColor = Theme.cyan500
            monitorButton.setTitleColor(UIColor.white, for: .normal)
        case .ignore:
            ignoreButton.backgroundColor = Theme.grey500
            ignoreButton.setTitleColor(UIColor.white, for: .normal)
        }

        activityIndicator = UIActivityIndicatorView.init()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        view.addSubview(activityIndicator)
    }

    // MARK: Local Functions

    func changeButtonColors (type: Pin.Types, showIndicator: Bool = false) {
        let bgClr: UIColor
        let buttons = view.subviews.filter({vw in vw is UIButton}) as! [UIButton]

        // Resetting button styles
        buttons.forEach({btn in
            btn.backgroundColor = UIColor.white
            btn.setTitleColor(UIColor.blue, for: .normal)
        })

        // Updating style for selected button
        var selectedButton: UIButton
        switch type {
        case .control:
            bgClr = onOffSwitch.isOn ? Theme.lightGreen500 : Theme.amber500
            selectedButton = controlButton
        case .monitor:
            bgClr = Theme.cyan500
            selectedButton = monitorButton
        case .ignore:
            bgClr = Theme.grey500
            selectedButton = ignoreButton
        }

        selectedButton.backgroundColor = bgClr
        selectedButton.setTitleColor(UIColor.white, for: .normal)

        if showIndicator {
            // Placing indicator close to selected button
            let dim = selectedButton.frame.size.height
            let frame = CGRect(
                origin: CGPoint(x: view.bounds.size.width - dim, y: selectedButton.frame.origin.y),
                size: CGSize(width: dim, height: dim))
            activityIndicator.frame = frame
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        }
    }

    @IBAction func onUpdateType(_ sender: UIButton) {
        guard isEditing else { return }

        // Recording types
        var nextType: Pin.Types
        let oldType = self.pin.type
        let typeName = sender.titleLabel!.text!.lowercased()

        switch typeName {
        case "control":
            nextType = .control
        case "monitor":
            nextType = .monitor
        default:
            nextType = .ignore
        }

        self.changeButtonColors(type: nextType, showIndicator: true)

        // Applying change to device
        let gpio = Int(self.pin.boardName.components(separatedBy: " ")[1])

        let function = nextType == .control ? "out" : "in"
        self.webAPI.setFunction(gpioNumber: gpio!, functionType: function) { newFunction in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }

            // Reverting UI changes on API response failure
            guard newFunction != nil else {
                SharedSnackbar.show(parent: self.view, type: .error, message: "Cannot update")
                self.changeButtonColors(type: oldType)
                return
            }

            let name = self.nameBox.text!.isEmpty ? self.nameBox.text! : self.pin!.name
            let value = self.onOffSwitch.isOn ? 1 : 0

            // Notifying parent view controller to update pin data in layout
            NotificationCenter.default.post(name: Notification.Name.updatePinInLayout, object: self, userInfo: [
                    "id": String(self.pin!.id), "name": name, "type": nextType, "value": value])
        }
    }

    @IBAction func onUpdateValue() {
        guard isEditing else {
            // Reverting action
            onOffSwitch.isOn = !onOffSwitch.isOn
            return
        }

        onOffLabel.text = onOffSwitch.isOn ? "On" : "Off"
        controlButton.backgroundColor = onOffSwitch.isOn ? Theme.lightGreen500 : Theme.amber500

        let gpio = Int(self.pin.boardName.components(separatedBy: " ")[1])
        let value = self.onOffSwitch.isOn ? 1 : 0
        self.webAPI.setValue(gpioNumber: gpio!, value: value) { newValue in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }

            guard newValue != nil else {
                SharedSnackbar.show(parent: self.view, type: .error, message: "Cannot update")
                return
            }

            let name = self.nameBox.text!.isEmpty ? self.nameBox.text! : self.pin!.name

            // Notifying parent view controller to update pin data in layout
            NotificationCenter.default.post(name: Notification.Name.updatePinInLayout, object: self, userInfo: [
                "id": String(self.pin!.id), "name": name, "type": self.pin!.type, "value": value])
        }
    }
}
