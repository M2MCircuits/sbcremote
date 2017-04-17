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

    var pin: Pin!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Styling based on initial pin data
        if !pin!.name.isEmpty {
            nameBox.text = pin!.name
        }

        header.text = "#" + String(describing: pin!.id)
        onOffLabel.text = pin!.value == 1 ? "On" : "Off"
        onOffSwitch.isOn = pin!.value == 1
        onOffSwitch.isEnabled = isEditing

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
    }

    // MARK: Local Functions

    @IBAction func onUpdateType(_ sender: UIButton) {
        guard isEditing else { return }

        let bgClr: UIColor
        let buttons = view.subviews.filter({vw in vw is UIButton}) as! [UIButton]
        let type = sender.titleLabel!.text!.lowercased()

        // Resetting button styles
        buttons.forEach({btn in
            btn.backgroundColor = UIColor.white
            btn.setTitleColor(UIColor.blue, for: .normal)
        })

        // Updating style for selected button
        switch type {
        case "control": bgClr = onOffSwitch.isOn ? Theme.lightGreen500 : Theme.amber500
        case "monitor": bgClr = Theme.cyan500
        case "ignore": bgClr = Theme.grey500
        default: bgClr = UIColor.red
        }

        sender.backgroundColor = bgClr
        sender.setTitleColor(UIColor.white, for: .normal)

        // Notifying parent view controller to update pin data in layout
        NotificationCenter.default.post(name: Notification.Name.updatePin, object: self, userInfo: [
            "id": String(pin!.id), "name": nameBox.text!, "type": type, "value": String(onOffSwitch.isOn)])
    }

    @IBAction func onUpdateValue() {
        guard isEditing else {
            // Reverting action
            onOffSwitch.isOn = !onOffSwitch.isOn
            return
        }
        
        onOffLabel.text = onOffSwitch.isOn ? "On" : "Off"
        controlButton.backgroundColor = onOffSwitch.isOn ? Theme.lightGreen500 : Theme.amber500

        // Notifying parent view controller to update pin data in layout
        NotificationCenter.default.post(name: Notification.Name.updatePin, object: self, userInfo: [
            "id": String(pin!.id), "name": pin!.name, "type": String(describing: pin!.type), "value": String(onOffSwitch.isOn)])
    }
}
