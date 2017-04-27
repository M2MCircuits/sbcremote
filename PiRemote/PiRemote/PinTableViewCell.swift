//
//  PinTableViewCell.swift
//  PiRemote
//
//  Authors: Muhammad Martinez
//  Copyright (c) 2017 JLL Consulting. All rights reserved.
//

import UIKit

class PinTableViewCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pinNameLabel: UILabel!
    @IBOutlet weak var pinView: UIButton!
    @IBOutlet weak var valueSwitch: UISwitch!
    @IBOutlet weak var typeLabel: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: Local Functions

    @IBAction func onToggleSwitch(_ sender: UISwitch) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        // Notifying parent view controller to update pin data in layout
        NotificationCenter.default.post(name: Notification.Name.updatePin, object: self, userInfo: [
            "id": pinView.tag, "value": String(sender.isOn)])
    }

    func updateStyle(with pin: Pin) {
        // Capitalzing first letter of type
        var prettyType = String(describing: pin.type)
        prettyType = String(prettyType.characters.prefix(1)).uppercased() + String(prettyType.characters.dropFirst())

        typeLabel.text = prettyType

        let (bgClr, borderClr) = pin.getColors()

        pinView.backgroundColor = bgClr
        pinView.layer.borderColor = borderClr.cgColor
        pinView.layer.borderWidth = 4.0
        pinView.layer.cornerRadius = pinView.bounds.size.width / 2
        pinView.setTitle("\(pin.id)", for: UIControlState.normal)
        pinView.setTitleColor(Theme.grey900, for: .normal)
        pinView.tag = pin.id
        pinView.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)

        pinNameLabel.text = pin.name.isEmpty ? pin.boardName : pin.name

        valueSwitch.isOn = pin.value == 1
        valueSwitch.isEnabled = pin.type == .control
        valueSwitch.isHidden = pin.type != .control

        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
}
