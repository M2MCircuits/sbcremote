//
//  PinSetupScrollView.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 4/9/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

class PinSetupScrollView: UIScrollView {

    // MARK: Local Variables

    var contentView: UIView?
    var selection: Int!
    var btnSize = 60 as CGFloat
    var btnMargin = 4 as CGFloat

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        autoresizingMask = UIViewAutoresizing.flexibleHeight
        contentSize = CGSize(width: frame.width * 2, height: btnSize * 25.0)

        // TODO: Determine why scroll view is loading with top offset
        let defaultTopMargin = 80 as CGFloat
        contentOffset = CGPoint(x: (contentSize.width / 4), y: defaultTopMargin)

        contentView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: contentSize))
        contentView?.backgroundColor = UIColor(patternImage: UIImage(named: "circuit")!)


        let midX = contentView!.frame.midX
        let maxPins = PinHeader.modelB.count// TODO: Handle other pi versions
        var isEven: Bool
        var x, y, margin: CGFloat

        // Positioning buttons with respect to scrollview coordinate system
        for i in 1...maxPins {
            isEven = i % 2 == 0
            margin = (isEven ? btnSize * 1.25 : -btnSize * 2.25)
            x = isEven ? midX + btnMargin : midX - btnSize - btnMargin
            y = ((btnSize + (btnMargin * 2)) * floor(CGFloat(i - 1) / 2)) + btnSize

            let btnLocation = CGPoint(x: x, y: y)
            let pinLocation = CGPoint(x: x + margin, y: y)
            let pinButton = buildPinButton(for: i, location: btnLocation)
            let pinLabel = buildPinLabel(for: i, location: pinLocation)

            contentView?.addSubview(pinButton)
            contentView?.addSubview(pinLabel)
        }

        addSubview(contentView!)
    }

    // MARK: Local Functions

    func buildPinButton(for id: Int, location: CGPoint) -> UIButton {
        let btn = UIButton(frame: CGRect(origin: location, size: CGSize(width: btnSize, height: btnSize)))
        btn.addTarget(self, action: #selector(PinSetupScrollView.handleTouchTap), for: .touchUpInside)
        btn.backgroundColor = UIColor.red
        btn.layer.borderWidth = 4.0
        btn.layer.cornerRadius = btnSize / 2
        btn.setTitle("\(id)", for: UIControlState.normal)
        btn.tag = id
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 32.0)
        return btn
    }

    func buildPinLabel(for id: Int, location: CGPoint) -> UILabel {
        let fontSize = 24.0 as CGFloat
        let label = UILabel(frame:
            CGRect(origin: location, size: CGSize(width: btnSize * 2, height: btnSize + (btnMargin * 2))))
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.tag = id
        label.text = "func #"
        label.textAlignment = .center
        label.textColor = Theme.grey900
        return label
    }

    func handleTouchTap(sender: UIButton) {
        let i = sender.tag
        let horizontalOffset = i % 2 == 0 ? btnSize * 6 : (btnMargin * 2)
        let verticalOffset = ((i - 1) / 2) * Int(btnSize - (btnMargin * 2)) - Int(btnSize)
        let offset = CGPoint(x: horizontalOffset, y: CGFloat(verticalOffset))

        scrollToPoint(point: offset)
        NotificationCenter.default.post(name: Notification.Name.touchPin, object: self, userInfo: ["tag": i])
    }

    func scrollToPoint(point: CGPoint) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.contentOffset = point
            }, completion: nil)
        }
    }

    func setPinData(pins: [Pin]) {
        // Colorcoding pins
        for child in contentView!.subviews {
            if child is UIButton {
                let btn = child as! UIButton
                let i = btn.tag
                let (bgClr, borderClr) = pins[i - 1].getColors()

                btn.backgroundColor = bgClr
                btn.layer.borderColor = borderClr.cgColor
                btn.setTitleColor(Theme.grey900, for: UIControlState.normal)
            } else if child is UILabel {
                let label = child as! UILabel
                let i = label.tag
                let pinName = pins[i-1].name.isEmpty ? pins[i-1].boardName : pins[i-1].name
                let (bgClr, borderClr) = pins[i - 1].getColors()

                label.backgroundColor = bgClr.withAlphaComponent(0.5)
                label.layer.borderColor = borderClr.withAlphaComponent(0.5).cgColor
                label.layer.borderWidth = 4.0
                label.text = pinName
            }
        }
        setNeedsDisplay()
    }

}
