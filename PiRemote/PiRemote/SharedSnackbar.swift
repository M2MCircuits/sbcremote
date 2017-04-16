//
//  SharedSnackbar.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 4/16/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

class SharedSnackbar: UIView {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!

    enum IconName: String {
        case error = "cross"
        case warn = "warning"
        case info = "info"
        case check = "checkmark"
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: Utility Functions

    static func show(parent: UIView, type: IconName, message: String) {
        let nib = Bundle.main.loadNibNamed("SharedSnackbar", owner: parent, options: nil)?[0] as! SharedSnackbar
        let nibHeight = nib.bounds.height
        let parentHeight = parent.bounds.height
        let waitTimeInSeconds = UInt32(4)

        let initalFrame = CGRect(origin: CGPoint(x: 0, y: parentHeight),
                                 size: CGSize(width: parent.bounds.width, height: nib.bounds.height))
        let targetFrame = CGRect(origin: CGPoint(x: 0, y: parentHeight - nibHeight),
                                 size: CGSize(width: parent.bounds.width, height: nib.bounds.height))

        // Styling view
        nib.frame = initalFrame
        nib.iconImageView.image = UIImage(named: type.rawValue)
        nib.iconImageView.contentMode = .scaleAspectFit
        nib.messageLabel.text = message

        switch type {
        case .check: nib.backgroundColor = Theme.lightGreen300
        case .error: nib.backgroundColor = Theme.red300
        case .info: nib.backgroundColor = Theme.cyan300
        case .warn: nib.backgroundColor = Theme.amber300
        }

        parent.addSubview(nib)

        // Animating into then out of parent view
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                nib.frame = targetFrame
            }, completion: { isComplete in if isComplete {
                sleep(waitTimeInSeconds)
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    nib.frame = initalFrame
                }, completion: {isComplete in if isComplete {
                    nib.removeFromSuperview()
                }})
            }})
        }
    }
}
