//
//  PinSettingsView.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 3/29/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

class PinSettingsView: UIView {

    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var nameBox: UITextField!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @IBAction func onSetType(_ sender: Any) {
        print(sender)
    }
}
