//
//  PiDiagramViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 4/11/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

class PiDiagramViewController: UIViewController {

    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let diagram = UIImage(named: getFilePathToPinDiagram())

        header.text = "Raspberry Pi 3 Model B"

        // Order is important: resizes content after the image has been added to it.
        imageView.image = diagram
        imageView.contentMode = .scaleAspectFit
    }

    // MARK: Local Functions

    @IBAction func onDismiss(_ sender: UIBarButtonItem) {
        dismiss(animated: false)
    }

    func getFilePathToPinDiagram() -> String {
        // Only supports Raspberry Pi 3 for now
        return PiFilePaths.rPi3
    }
}
