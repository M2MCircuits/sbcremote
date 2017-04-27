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

        let waitTimeInSeconds = 4.0
        _ = Timer.scheduledTimer(timeInterval: waitTimeInSeconds, target: self, selector: #selector(self.animateOut), userInfo: nil, repeats: false);
    }

    // MARK: Local Functions

    func animateOut() {
        // Preventing animations if view is not being shown
        guard self.superview != nil else {
            return
        }
        let parentHeight = self.superview?.bounds.height
        let parentWidth = self.superview?.bounds.height
        let initalFrame = CGRect(origin: CGPoint(x: 0, y: parentHeight!),
                                 size: CGSize(width: parentWidth!, height: self.bounds.height))

        // Animating out of parent view
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.frame = initalFrame
        }, completion: {isComplete in if isComplete {
            self.removeFromSuperview()
        }})
    }

    // MARK: Utility Functions

    static func show(parent: UIView, type: IconName, message: String) {
        let nib = Bundle.main.loadNibNamed("SharedSnackbar", owner: parent, options: nil)?[0] as! SharedSnackbar
        let nibHeight = nib.bounds.height
        let parentHeight = parent.bounds.height

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

        // Adding to parent
        parent.addSubview(nib)

        // Animating into the parent view
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                nib.frame = targetFrame
            }, completion: nil)
        }
    }
}
