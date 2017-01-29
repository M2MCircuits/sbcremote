//
//  PinTableViewController.swift
//  PiRemote
//
//  Authors: Hunter Heard, Josh Binkley
//  Copyright (c) 2016 JLL Consulting. All rights reserved.
//

import UIKit

class PinTableViewController: UITableViewController {
    
    //MARK Properties
    
    
    var pins = [Pin]();
    
    //var tbc = MyTabBarController();

    
    
    

    /*
    @IBAction func switchHit(sender: PinUISwitch) {
        
        pins[sender.pinNumber].changeState();
        
    }
    */
    
    @IBAction func switchHit(_ sender: PinUISwitch) {

        print("YOU SWITCH DEVIL!");
        
        let number = sender.pinNumber;
        let tbc = self.parent as! MyTabBarController;
        
        let cell = getCellForPinNumber(number!);
        
        
        if(sender.pinNumber < 0 || sender.pinNumber >= pins.count)
        {
            return;
        }
        
        //send request to raspberry pi to change state
        
        
        cell.spinner.startAnimating();
        sender.isEnabled = false;
        
        tbc.setPin(number, newState: !pins[number].on);
        
        
        //pins[sender.pinNumber].changeState();
        //printPinList();
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //load the samples
        //loadSamplePins();
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    func loadSamplePins()
    {
        let pin1 = Pin(name: "Water", Hname: "Flow", Lname: "Stop", type: 1)
        let pin2 = Pin(name: "Light", Hname: "On", Lname: "Off", type: 1)
        let pin3 = Pin(name: "Door", Hname: "Open", Lname: "Closed", type: 2)
        let pin4 = Pin(name: "Bulb", Hname: "On", Lname: "Off", type: 1)
        let pin5 = Pin(name: "Garage Sensor", Hname: "Motion", Lname: "Still", type: 2)
        let pin6 = Pin(name: "Flood Sensor", Hname: "Flooded", Lname: "Not Flooded", type: 2)
        let pin7 = Pin(name: "Sprinkler", Hname: "Running", Lname: "Off", type: 1)
        let pin8 = Pin(name: "Stove", Hname: "On", Lname: "Off", type: 1)
        
        pins += [pin1,pin2,pin3,pin4,pin5,pin6,pin7,pin8];
        
        
        
    }
    
    func numberOfMonitorPins() -> Int
    {
        var n = 0;
        
        for p in pins{
            if(p.type == 2)
            {
                n += 1;
            }
            
        }
        
        return n;
    }
    
    func numberOfControlPins() -> Int
    {
        var n = 0;
        
        for p in pins{
            if(p.type == 1)
            {
                n += 1;
            }
            
        }
        
        return n;
    }
    
    func numberOfPinsOfType(_ type: Int) -> Int
    {
        if(type == 0)
        {
            return pins.count - numberOfControlPins() - numberOfMonitorPins();
        }
        
        if(type == 1)
        {
            return numberOfControlPins();
        }
        
        if(type == 2)
        {
            return numberOfMonitorPins();
        }
        
        return 0;
    }
    
    func printPinList()
    {
        
    
        for p in pins{
            print(p.name, terminator: "");
            print(" ", terminator: "");
            print(p.stateName, terminator: "");
            
            print("");
            
        }
        
        
        print("");
        
    }
    
    
    //gets the pin number of the pin that belongs in the section and row
    //(except here it's type instead of section
    //if section == 0 then type == 1
    //if section == 1 then type == 2
    func getPinDegree(_ type: Int, degree: Int) -> Int
    {
        
        var count = -1;
        var I = 0;
        for p in pins{
            
            if(p.type == type)
            {
                count = count + 1;
                
                if(count == degree)
                {
                    return I;
                }
                
            }
            
            I = I + 1;
        }
        
        return -1;
    }
    
    func getCellForPinNumber(_ pNumber: Int) -> PinTableViewCell
    {
        let p = pins[pNumber];
        
        
        let section = p.type - 1;
        
        
        var cell = PinTableViewCell();
        
        for ind in 0 ... numberOfPinsOfType(p.type)-1
        {
            
            
            cell = getCellForSectionIndex(section, index: ind);
            if(cell.onState.pinNumber == pNumber)
            {
                break;
            }
        }
        
        
        return cell;
    }
    
    func getCellForSectionIndex(_ section: Int, index: Int) -> PinTableViewCell
    {
        let path = IndexPath(row: index, section: section);
        
        let cell = tableView.cellForRow(at: path) as! PinTableViewCell;
        
        
        return cell;
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        // Return the number of sections.
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        
        if(section == 0)
        {
            return numberOfControlPins();
        }
        
        return numberOfMonitorPins();
    }

    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //ask someone what these mean
        let cellIdentifier = "PinTableViewCell";
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PinTableViewCell

        
        
        
        
        //how to find out which pin to put in this cell
        //based on the cell's index and the cell's section
        
        let ind = getPinDegree(indexPath.section+1, degree:indexPath.row);
        
        let pin = pins[ind];
        
        
        // Configure the cell
        
        cell.nameLabel.text = pin.name;
        cell.HLnameLabel.text = pin.Hname;
        cell.Hlabel = pin.Hname;
        cell.Llabel = pin.Lname;
        
        cell.nameLabel.text = String(ind);
//        
        cell.onState.isOn = pin.on;
        cell.onState.pinNumber = ind;
        
        if(pin.type == 2)
        {
            cell.onState.isEnabled = false;
//            print("Set pin ");
//            print(ind);
//            println(" to disabled");
        }
        else
        {
            cell.onState.isEnabled = true;
        }
        
        if(cell.onState.isOn == false)
        {
            cell.HLnameLabel.text = pin.Lname;
        }
        else{
            cell.HLnameLabel.text = pin.Hname;
        }

        
        
        

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
