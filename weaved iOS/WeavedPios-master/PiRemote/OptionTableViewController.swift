//
//  OptionTableViewController.swift
//  PiRemote
//
//  Authors: Hunter Heard, Josh Binkley
//  Copyright (c) 2016 JLL Consulting. All rights reserved.
//

import UIKit

class OptionTableViewController: UITableViewController {

    
    
    
    var pins = [Pin]()
    
    
    //if the "type" button on a cell is pressed
    //this function will use the button's tag
    //as an index for pins and change that pin's type
    @IBAction func typeButtonPress(sender: UIButton) {
        
        if(sender.tag < 0 || sender.tag >= pins.count)
        {
            return;
        }
        
        let tbc = self.parentViewController as! MyTabBarController;
        
        
        sender.enabled = false;
        
        tbc.setFunction(sender, newFunction: !pins[sender.tag].function)
        

        
        //Where's that list of webiopi http commands?
        
        
        
    }
    
    
    @IBAction func nameChange(sender: UITextField) {
        
        if(sender.tag < 0 || sender.tag >= pins.count)
        {
            return;
        }
        pins[sender.tag].setHname(sender.text!);
        
        let tbc = self.parentViewController as! MyTabBarController;
        let otherView = tbc.childViewControllers[0] as! PinTableViewController;
        otherView.getCellForPinNumber(sender.tag).nameLabel.text=sender.text;
        otherView.getCellForPinNumber(sender.tag).setNeedsDisplay();
        
        otherView.pins = self.pins;
        tbc.tabBarPins = pins;
        
        //syncWithTable();

    }
    
    
    @IBAction func HnameChange(sender: UITextField) {
        if(sender.tag < 0 || sender.tag >= pins.count)
        {
            return;
        }
        
        pins[sender.tag].setHname(sender.text!);
        
        let tbc = self.parentViewController as! MyTabBarController;
        let otherView = tbc.childViewControllers[0] as! PinTableViewController;
        otherView.getCellForPinNumber(sender.tag).Hlabel=sender.text;
        otherView.getCellForPinNumber(sender.tag).setNeedsDisplay();
        
        otherView.pins = self.pins;
        tbc.tabBarPins = pins;
        
        //syncWithTable();

    }

    
    @IBAction func LnameChange(sender: UITextField) {
        if(sender.tag < 0 || sender.tag >= pins.count)
        {
            return;
        }
        
        pins[sender.tag].setLname(sender.text!);
        
        let tbc = self.parentViewController as! MyTabBarController;
        let otherView = tbc.childViewControllers[0] as! PinTableViewController;
        otherView.getCellForPinNumber(sender.tag).Llabel=sender.text;
        otherView.getCellForPinNumber(sender.tag).setNeedsDisplay();
        
        otherView.pins = self.pins;
        tbc.tabBarPins = pins;
        
        //syncWithTable();

    }
    
    
    /*
    @IBAction func typeButtonPress(sender: UIButton) {
        
        if(sender.tag < 0 || sender.tag >= pins.count)
        {
            return;
        }
        
        pins[sender.tag].changeType();
        
        
    }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        if pins.count == 0
        {
            
            //loadSamplePins();
            
//            var tempPin = Pin();
//            for i in 1...8
//            {
//                pins += [tempPin];
//            }
            
            
        }
        
        

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
            if(!p.function && p.isGPIO)
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
            if(p.function && p.isGPIO)
            {
                n += 1;
            }
            
        }
        
        return n;
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
    
    
    //what does this do here?
    func getPinDegree(type: Int, degree: Int) -> Int
    {
        
        var count = -1;
        var I = 0;
        for p in pins{
            
            if(p.type == type && p.isGPIO)
            {
                count += 1;
                
                if(count == degree)
                {
                    return I;
                }
                
            }
            
            I += 1;
        }
        
        return -1;
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    func numberOfGPIOPins() -> Int
    {
        var count = 0;
        
        for p in pins
        {
            if(p.isGPIO)
            {
                count += 1;
            }
        }
        
        return count;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        // Return the number of rows in the section.
        
        return pins.count;
        
    }


    //not used
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "segueUno" {
            let viewControllerB = segue.destinationViewController as! PinTableViewController
            viewControllerB.pins = self.pins;
        }
    }
    
    //copies this object's pins array into the main PinTableViewController
    func syncWithTable()
    {
        //self.performSegueWithIdentifier("segueUno", sender: self);

        //tbc is the TabBarController that contains all the views
        let tbc = self.parentViewController as! MyTabBarController;
        
        print("Syncing with table");
        
        
        
        //otherView is the PinTableViewController where we look at the pins and their states
        //  (right now the index is 0 because PTVC is the first view we look at)
        //  (I'd like to change this and make the Login screen (LoginViewController) the first one but I would probably break it)
        let otherView = tbc.childViewControllers[0] as! PinTableViewController;
        
        otherView.pins = self.pins;
        
        //otherView.printPinList();
        
        tbc.tabBarPins = pins;
        
        //I think this calls tableView(), which means all the cells get re-initialized, which they need to if anything has changed here in the options
        otherView.tableView.reloadData();
        otherView.tableView.setNeedsDisplay();
        
    }
    
    func getCellAtIndex(index: Int) -> OptionTableViewCell
    {
        
        let path = NSIndexPath(forRow: index, inSection: 0);
        
        let cell = tableView.cellForRowAtIndexPath(path) as! OptionTableViewCell;
        
        return cell;
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //ask someone what these mean
        let cellIdentifier = "OptionTableViewCell";
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! OptionTableViewCell
        
        
        
        
        
        
        //right now the pins are tied to the index of the table and vice versa
        //so don't put anything else in the table
        let pin = pins[indexPath.row];
        
        
        // Configure the cell
        
        cell.nameLabel.text = pin.name;
        cell.Hlabel.text = pin.Hname;
        cell.Llabel.text = pin.Lname;
        
        cell.typeNumber = pin.type;
        cell.typeButton.tag = indexPath.row;
        cell.pinNumber = indexPath.row;
        
        cell.nameLabel.tag = indexPath.row;
        cell.Hlabel.tag = indexPath.row;
        cell.Llabel.tag = indexPath.row;
        
        cell.typeButton.setTitle(cell.getType(pin.type), forState: UIControlState.Normal)
        
        if(!pin.isGPIO)
        {
            cell.typeButton.enabled = false;
        }
        
        //print("Loading Option Table Cell ", terminator: "")
        //print(indexPath.row);
        
        
        
        
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
