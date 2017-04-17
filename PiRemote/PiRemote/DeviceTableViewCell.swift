//
//  DeviceTableViewCell.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 2/25/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

class DeviceTableViewCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
