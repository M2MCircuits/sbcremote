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

        // Positioning buttons with respect to scrollview coordinate system
        let midX = contentView!.frame.midX
        var isEven: Bool
        var x, y: CGFloat

        for i in 1...40 {
            isEven = i % 2 == 0
            x = isEven ? midX + btnMargin : midX - btnSize - btnMargin
            y = ((btnSize + (btnMargin * 2)) * floor(CGFloat(i - 1) / 2)) + btnSize

            let location = CGPoint(x: x, y: y)
            let pinButton = buildPinButton(for: i, location: location)

            contentView?.addSubview(pinButton)
        }

        addSubview(contentView!)
    }

    // MARK: Local Functions

    func buildPinButton(for id: Int, location: CGPoint) -> UIButton {
        let btn = UIButton(frame: CGRect(origin: location, size: CGSize(width: btnSize, height: btnSize)))
        btn.addTarget(self, action: #selector(PinSetupScrollView.handleTouchTap), for: .touchUpInside)
        btn.backgroundColor = UIColor.red
        btn.layer.borderWidth = 4.0
        btn.layer.cornerRadius = 8.0
        btn.setTitle("\(id)", for: UIControlState.normal)
        btn.tag = id
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 32.0)
        return btn
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
            guard child is UIButton else { break }

            let btn = child as! UIButton
            let i = btn.tag

            switch pins[i - 1].type {
            case .ignore:
                btn.backgroundColor = Theme.ignoreLightColor
                btn.layer.borderColor = Theme.ignoreDarkColor.cgColor
            case .monitor:
                btn.backgroundColor = Theme.monitorLightColor
                btn.layer.borderColor = Theme.monitorDarkColor.cgColor
            case .control:
                btn.backgroundColor = Theme.controlLightColor
                btn.layer.borderColor = Theme.controlDarkColor.cgColor
            }

            btn.setTitleColor(Theme.pinButtonTextColor, for: UIControlState.normal)
        }
        setNeedsDisplay()
    }

}
