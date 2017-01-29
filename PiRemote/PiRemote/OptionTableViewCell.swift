//
//  OptionTableViewCell.swift
//  PiRemote
//
//  Authors: Hunter Heard, Josh Binkley
//  Copyright (c) 2016 JLL Consulting. All rights reserved.
//

import UIKit

class OptionTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var Hlabel: UITextField!
    @IBOutlet weak var Llabel: UITextField!
    @IBOutlet weak var typeButton: UIButton!

    //@IBOutlet weak var typeButton: UIButton!
    var pinNumber = 0
    var typeNumber = 0
    @IBAction func typePress(_ sender: UIButton) {
        /*
        typeNumber++;
        
        if(typeNumber > 2)
        {
            typeNumber = 0;
        }
        
        sender.setTitle(getType(typeNumber), forState: UIControlState.Normal);
 
        */
    }

    /*
    @IBAction func TypeButtonPress(sender: UIButton) {
        
        typeNumber++;
        
        if(typeNumber > 2)
        {
            typeNumber = 0;
        }
        
        sender.setTitle(getType(typeNumber), forState: UIControlState.Normal);
        
        
    }
    */

    func getType(_ type: Int) -> String {
        if type == 0 {
            return "Ignore"
        }

        if type == 1 {
            return "OUT"
        }
        
        if type == 2 {
            return "IN"
        }

        return "Unknown"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
