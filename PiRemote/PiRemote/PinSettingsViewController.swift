//
//  PinSettingsViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 4/2/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

class PinSettingsViewController: UIViewController {

    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var nameBox: UITextField!

    // Local Variables
    var pin: Pin!

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        header.text = "#" + String(describing: pin!.id)
        nameBox.text = pin!.name
    }

    @IBAction func onSelectControl(_ sender: UIButton) {
        handleTypeChange(type: "control")
        sender.setTitleColor(UIColor.green, for: .normal)
    }

    @IBAction func onSelectIgnore(_ sender: UIButton) {
        handleTypeChange(type: "ignore")
        sender.setTitleColor(UIColor.green, for: .normal)
    }

    @IBAction func onSelectMonitor(_ sender: UIButton) {
        handleTypeChange(type: "monitor")
        sender.setTitleColor(UIColor.green, for: .normal)
    }

    func handleTypeChange(type: String) {
        let buttons = view.subviews.filter({vw in vw is UIButton}) as! [UIButton]
        buttons.forEach({btn in
            btn.setTitleColor(UIColor.blue, for: .normal)
        })

        NotificationCenter.default.post(
            name: Notification.Name.updatePin,
            object: self,
            userInfo: ["id": String(pin!.id), "name": nameBox.text!, "type": String(describing: type)])
    }
}
