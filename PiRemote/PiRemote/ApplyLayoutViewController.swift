//
//  ApplyLayoutViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 4/6/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

class ApplyLayoutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: Local Variables

    var savedLayoutNames: [String]!
    var selection: Int!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let data = UserDefaults.standard.object(forKey: "layoutNames") as? Data {
            savedLayoutNames = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String]!
        } else {
            savedLayoutNames = []
        }
    }

    // MARK: UITableViewDataSource Functions

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = savedLayoutNames[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedLayoutNames.count
    }

    // MARK: UITableViewDelegate Functions

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selection = indexPath.row
        return indexPath
    }

    // MARK: Local Functions

    @IBAction func onApply(_ sender: UIBarButtonItem) {
        guard let selection = selection else { return }
        let userInfo = ["layoutName": savedLayoutNames[selection]]
        NotificationCenter.default.post(name: Notification.Name.apply, object: nil, userInfo: userInfo)
    }

    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: false)
    }
}
