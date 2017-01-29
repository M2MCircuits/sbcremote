//
//  PinTableViewCell.swift
//  PiRemote
//
//  Authors: Hunter Heard, Josh Binkley
//  Copyright (c) 2016 JLL Consulting. All rights reserved.
//

import UIKit

class PinTableViewCell: UITableViewCell {
    //MARK: Properties
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var HLnameLabel: UILabel!
    @IBOutlet weak var onState: PinUISwitch!

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var Hlabel: String!
    var Llabel: String!
    
    /*
    @IBAction func switchMethod(sender: PinUISwitch) {
        
        if(sender.on)
        {
            HLnameLabel.text = Hlabel;
        }
        else
        {
            HLnameLabel.text = Llabel;
        }
    
    }
    */
    
    
    @IBAction func switchTrip(_ sender: PinUISwitch) {
        
//        if(sender.on)
//        {
//            HLnameLabel.text = Hlabel;
//        }
//        else
//        {
//            HLnameLabel.text = Llabel;
//        }
        
    }
    
    
    //var pinNum: Int
    
    

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
