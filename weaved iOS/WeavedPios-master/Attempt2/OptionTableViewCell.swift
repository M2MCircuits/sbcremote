//
//  OptionTableViewCell.swift
//  Attempt2
//
//  Created by Hunter Heard on 3/31/16.
//  Copyright (c) 2016 Hunter Heard. All rights reserved.
//

import UIKit

class OptionTableViewCell: UITableViewCell {

    

    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var Hlabel: UITextField!
    @IBOutlet weak var Llabel: UITextField!
    @IBOutlet weak var typeButton: UIButton!

    //@IBOutlet weak var typeButton: UIButton!
    
    
    
    var pinNumber = 0;
    
    var typeNumber = 0;
    

    @IBAction func typePress(sender: UIButton) {
        
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
    
    func getType(type: Int) -> String
    {
        if(type == 0)
        {
            return "Ignore"
        }
        
        if(type == 1)
        {
            return "OUT"
        }
        
        if(type == 2)
        {
            return "IN"
        }
        
        return "Unknown"
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
