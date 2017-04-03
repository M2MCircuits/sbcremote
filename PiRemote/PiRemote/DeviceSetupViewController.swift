//
//  DeviceSetupViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 2/26/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

// TODO: Handle different pi models. Currently supports Pi 3
class DeviceSetupViewController: UIViewController,
UIPickerViewDataSource, UIPickerViewDelegate, UIPopoverPresentationControllerDelegate, UIScrollViewDelegate {

    @IBOutlet weak var devicePicker: UIPickerView!
    @IBOutlet weak var scrollView: UIScrollView!

    // Local Variables
    var currentImageView: UIImageView!
    var currentLayout: PinLayout!
    var currentPin: Int!
    var popoverView: UIViewController!

    let pickerOptions = [
        DeviceTypes.rPi3
    ].self

    override func viewDidLoad() {
        super.viewDidLoad()

        currentPin = -1

        // Additional navigation setup
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(DeviceSetupViewController.onLeave))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(DeviceSetupViewController.onSetDeviceSettings))

        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.title = "Device Setup"

        // Additional subviews
        let imgWidth = 1335.0
        let imgHeight = 2000.0
        let scale = 0.67

        currentImageView = UIImageView(image: UIImage(named: "RaspberryPi_3B.png"))
        currentImageView.frame = CGRect(x: 0, y: 0, width: scale * imgWidth, height: scale * imgHeight)

        devicePicker.dataSource = self
        devicePicker.delegate = self

        let paddedWidth = currentImageView.bounds.width + 256

        scrollView.autoresizingMask = UIViewAutoresizing.flexibleHeight
        scrollView.backgroundColor = UIColor(red: 0xff, green: 0x00, blue: 0x00, alpha: 1.0)
        scrollView.contentSize = CGSize(width: paddedWidth, height: currentImageView.bounds.height)
        scrollView.contentOffset = CGPoint(x: 512, y: 68)
        scrollView.delegate = self

        scrollView.addSubview(currentImageView)

        // Add listeners for notifications from popovers
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleApplyLayout), name: NotificationNames.apply, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleClearLayout), name: NotificationNames.clear, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleShowPinDiagram), name: NotificationNames.diagram, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleSetWebLogin), name: NotificationNames.login, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleSaveLayout), name: NotificationNames.save, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleValidLogin), name: NotificationNames.loginSuccess, object: nil)


        // Build out GPIO UI
        buildScrollView()
    }

    override func viewDidLayoutSubviews() {
        scrollView!.maximumZoomScale = 2.0
        scrollView!.minimumZoomScale = 0.5
        scrollView!.setZoomScale(1.0, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        var contentSize: CGSize!
        var sourceRect: CGRect!

        switch segue.identifier! {
        case SegueTypes.idToPopoverApply:
            contentSize = CGSize(width: 360, height: 400)
        case SegueTypes.idToPopoverSave:
            contentSize = CGSize(width: 360, height: 200)
        case SegueTypes.idToPopoverClear:
            contentSize = CGSize(width: 360, height: 200)
        case SegueTypes.idToPopoverDiagram:
            contentSize = CGSize(width: 360, height: 700)
        case SegueTypes.idToPopoverLogin:
            contentSize = CGSize(width: 320, height: 320)
        case SegueTypes.idToPinSettings:
            contentSize = CGSize(width: 150, height: 250)
            sourceRect = CGRect(origin: CGPoint(x: 300, y: 0), size: destination.view.bounds.size)
        default: break
        }
        _ = PopoverViewController.buildPopover(
                source: self, content: destination, contentSize: contentSize, sourceRect: sourceRect)
    }

    // UIPickerViewDataSource Functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions.count
    }

    // UIPickerViewDelegate Functions
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOptions[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // TODO: Implement. Updates pi diagram based on selection
    }
    
    // UIScrollViewDelegate Functions
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return currentImageView
    }

    // Local Functions
    func handleApplyLayout() {
        print("APPLY")
    }

    func handleClearLayout() {
        print("CLEAR")
    }

    func handleSaveLayout() {
        print("SAVE")
    }

    func handleSetWebLogin() {
        print("WEBIOPI")
    }

    func handleShowPinDiagram() {
        print("DIAGRAM")
    }

    func handleValidLogin() {
        print("LOGIN IS VALID")
    }

    func buildScrollView() {
        let btnWidth = 28
        let btnHeight = 25
        var isEven: Bool
        var pinButton: UIButton
        var x, y: Int

        for i in 1...40 {
            // Positions with respect to image
            isEven = i % 2 == 0
            x = isEven ? 710 + btnWidth + 4 : 710
            y = (btnHeight + 8) * ((i - 1) / 2) + 208

            pinButton = UIButton(type: UIButtonType.roundedRect) as UIButton

            pinButton.backgroundColor = UIColor.red
            pinButton.frame = CGRect(x: x, y: y, width: btnWidth, height: btnHeight)
            pinButton.setTitle("\(i)", for: UIControlState.normal)
            pinButton.setTitleColor(UIColor.yellow, for: UIControlState.normal)

            let singleTap = UITapGestureRecognizer(target: self, action: #selector(DeviceSetupViewController.onTouchTap))

            scrollView.addGestureRecognizer(singleTap)

            currentImageView.addSubview(pinButton)
        }
    }

    func onLeave(sender: UIButton!) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    func onSetDeviceSettings(sender: UIButton!) {
        // TODO: Implement saving the layout
        onLeave(sender: sender!)
    }

    func onTouchTap(gesture: UITapGestureRecognizer) {
        let touch = gesture.location(in: scrollView) as CGPoint
        let selection = self.currentImageView.subviews.first(where: {child in
            guard (child is UIButton) else { return false }
            return child.frame.contains(touch)
        });

        if selection != nil {
            // Identify pin being touched
            let pinNumber = Int(((selection as! UIButton).titleLabel?.text)!)
            _ = pinNumber! % 2 == 0 // TODO: Use isEven
            let offset = CGSize(width: -64, height: -112)

            performSegue(withIdentifier: SegueTypes.idToPinSettings, sender: pinNumber)

            // Scroll over to pin
            goToPoint(point: CGPoint(x: touch.x + offset.width, y: touch.y + offset.height))
        }
    }
    
    // Prevents popover from changing style based on the iOS device
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    // TODO: Tweak for a smoother movement
    func goToPoint(point: CGPoint) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.scrollView.contentOffset = point
            }, completion: nil)
        }
    }
}
