//
//  ListTableViewCell.swift
//  PiRemote
//
//  Authors: Hunter Heard, Josh Binkley
//  Copyright (c) 2016 JLL Consulting. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var aliasLabel: UILabel!

    @IBOutlet weak var userNameLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!

    @IBOutlet weak var spinner: UIActivityIndicatorView!

    @IBOutlet weak var devLogButton: UIButton!

    @IBAction func devButtonPress(_ sender: UIButton) {
        //spinner.startAnimating();

        //lock all other buttons
        //start rotating thing
        //attempt to login to the device
        //finish attempt
        //stop rotating thing
        //unlock all buttons
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setName(_ name: String) {
        aliasLabel.text = name
    }

    func setLog(_ logged: Bool) {
        if logged {
            devLogButton.setTitle("Logged In", for: UIControlState())
            //backgroundColor = UIColor(red:0.50, green:1.00, blue:0.70, alpha:1.0);
        } else {
            devLogButton.setTitle("Login", for: UIControlState())
            //backgroundColor = UIColor(red:0.50, green:0.88, blue:1.00, alpha:1.0);
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
