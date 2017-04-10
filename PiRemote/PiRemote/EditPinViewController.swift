//
//  EditPinViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 4/9/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

//
//  PinSettingsViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 4/2/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

class EditPinViewController: UIViewController {

    @IBOutlet weak var controlButton: UIButton!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var ignoreButton: UIButton!
    @IBOutlet weak var monitorButton: UIButton!
    @IBOutlet weak var nameBox: UITextField!

    // MARK: Local Variables
    var pin: Pin!


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !pin!.name.isEmpty {
            nameBox.text = pin!.name
        }

        header.text = "#" + String(describing: pin!.id)

        switch pin!.type {
        case .control:
            controlButton.backgroundColor = Theme.controlDarkColor
            controlButton.setTitleColor(UIColor.white, for: .normal)
        case .monitor:
            monitorButton.backgroundColor = Theme.monitorDarkColor
            monitorButton.setTitleColor(UIColor.white, for: .normal)
        case .ignore:
            ignoreButton.backgroundColor = Theme.ignoreDarkColor
            ignoreButton.setTitleColor(UIColor.white, for: .normal)
        }
    }

    @IBAction func onSelectControl(_ sender: UIButton) {
        guard isEditing else { return }
        handleTypeChange(type: "control")
        sender.backgroundColor = Theme.controlDarkColor
        sender.setTitleColor(UIColor.white, for: .normal)
    }

    @IBAction func onSelectIgnore(_ sender: UIButton) {
        guard isEditing else { return }
        handleTypeChange(type: "ignore")
        sender.backgroundColor = Theme.ignoreDarkColor
        sender.setTitleColor(UIColor.white, for: .normal)
    }

    @IBAction func onSelectMonitor(_ sender: UIButton) {
        guard isEditing else { return }
        handleTypeChange(type: "monitor")
        sender.backgroundColor = Theme.monitorDarkColor
        sender.setTitleColor(UIColor.white, for: .normal)
    }

    func handleTypeChange(type: String) {
        // Reset colors for buttons
        let buttons = view.subviews.filter({vw in vw is UIButton}) as! [UIButton]
        buttons.forEach({btn in
            btn.backgroundColor = UIColor.white
            btn.setTitleColor(UIColor.blue, for: .normal)
        })

        NotificationCenter.default.post(
            name: Notification.Name.updatePin,
            object: self,
            userInfo: ["id": String(pin!.id), "name": nameBox.text!, "type": String(describing: type)])
    }
}
