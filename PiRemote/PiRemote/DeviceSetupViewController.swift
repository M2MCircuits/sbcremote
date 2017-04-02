//
//  DeviceSetupViewController.swift
//  PiRemote
//
//  Created by Muhammad Martinez on 2/26/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

class DeviceSetupViewController: UIViewController,
    UIPickerViewDataSource,
    UIPickerViewDelegate,
    UIPopoverPresentationControllerDelegate,
    UIScrollViewDelegate {

    @IBOutlet weak var devicePicker: UIPickerView!
    @IBOutlet weak var scrollView: UIScrollView!

    // Local Variables
    var currentPin: Int!
    var currentImageView: UIImageView!
    var pinSetupView: PinSettingsView!

    // TODO: Add configurations for different pi models
//    let pickerData = [
//        "Raspberry Pi 1 Model A",
//        "Raspberry Pi 1 Model B",
//        "Raspberry Pi 1 Model B+",
//        "Raspberry Pi 2",
//        "Raspberry Pi 3 Model B",
//        "Raspberry Pi Zero W",
//        "Raspberry Pi Zero"
//    ]

    let pickerData = ["Raspberry Pi 3 Model B"]

    override func viewDidLoad() {
        super.viewDidLoad();

        currentPin = -1

        // Additional navigation setup
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(DeviceSetupViewController.onCancel))
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(DeviceSetupViewController.onSaveChanges))

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

        let nib = Bundle.main.loadNibNamed("PinSettingsView", owner: self, options: nil)
        pinSetupView = nib!.first as! PinSettingsView
        (pinSetupView as UIView).isHidden = true

        let paddedWidth = currentImageView.bounds.width + 256

        scrollView.autoresizingMask = UIViewAutoresizing.flexibleHeight
        scrollView.backgroundColor = UIColor(red: 0xff, green: 0x00, blue: 0x00, alpha: 1.0)
        scrollView.contentSize = CGSize(width: paddedWidth, height: currentImageView.bounds.height)
        scrollView.contentOffset = CGPoint(x: 512, y: 68)
        scrollView.delegate = self

        scrollView.addSubview(currentImageView)
        // Build out GPIO UI
        buildScrollView()
    }

    override func viewDidLayoutSubviews() {
        scrollView!.maximumZoomScale = 2.0
        scrollView!.minimumZoomScale = 0.5
        scrollView!.setZoomScale(1.0, animated: true)
    }

    // UIPickerViewDataSource Functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    // UIPickerViewDelegate Functions
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // TODO: Implement. Updates pi diagram based on selection
    }
    
    // UIScrollViewDelegate Functions
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return currentImageView
    }


    // Local Functions
    @IBAction func onSetWebLogin(_ sender: Any) {
        // Get a reference to the view controller for the popover
        let content = storyboard?.instantiateViewController(withIdentifier: "WEB_DIALOG")
        (content  as! WebLoginViewController).onLoginSuccess = {() -> () in
            self.performSegue(withIdentifier: SegueTypes.idToDeviceDetails, sender: nil)
        }
        _ = buildPopoverView(for: content!)
        self.present(content!, animated: true, completion: nil)
    }

    func onSaveChanges(sender: UIButton!) {
        // TODO: Implement saving the layout
        self.dismiss(animated: true, completion: nil)
    }

    func onCancel(sender: UIButton!) {
        self.dismiss(animated: true, completion: nil)
    }

    // Prevents popover from changing style based on the iOS device
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    // TODO: Handle duplicate code in DevicesTableViewController.swift
    func buildPopoverView(
        for controller: UIViewController,
        direction: UIPopoverArrowDirection? = .up,
        position: CGPoint? = nil) -> UIPopoverPresentationController {
        controller.modalPresentationStyle = .popover

        // Container for the content
        let popover = controller.popoverPresentationController
        popover?.delegate = self
        popover?.sourceView = self.view
        popover?.permittedArrowDirections = direction!

        // TODO: Center popover based on device

        // Set size based on controller
        if (type(of: controller) == WebLoginViewController.self) {
            popover?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 360, height: 420)
        }

        return popover!
    }

    func buildScrollView() {
        // Positions do not change based on device...?

        let btnWidth = 28
        let btnHeight = 25
        var isEven: Bool
        var pinButton: UIButton
        var x, y: Int

        for i in 1...40 {
            isEven = i % 2 == 0
            x = isEven ? 710 + btnWidth + 4 : 710
            y = (btnHeight + 8) * ((i - 1) / 2) + 208

            pinButton = UIButton(type: UIButtonType.roundedRect) as UIButton

            pinButton.backgroundColor = UIColor.red
            pinButton.frame = CGRect(x: x, y: y, width: btnWidth, height: btnHeight)
            pinButton.setTitle("\(i)", for: UIControlState.normal)
            pinButton.setTitleColor(UIColor.yellow, for: UIControlState.normal)

            let singleTap = UITapGestureRecognizer(target: self, action: #selector(DeviceSetupViewController.onTouchTap))
//          let pan = UIPanGestureRecognizer(target: self, action: #selector(DeviceSetupViewController.onPanOver))

            scrollView.addGestureRecognizer(singleTap)
//          scrollView.addGestureRecognizer(pan)

            currentImageView.addSubview(pinButton)
        }
    }

//    func onPanOver(gesture: UIPanGestureRecognizer) {
//        let touchPoint = gesture.location(in: scrollView) as CGPoint
//        print("panning over \(touchPoint)")
//    }

    func onTouchTap(gesture: UITapGestureRecognizer) {
        let touch = gesture.location(in: scrollView) as CGPoint


        /*
         * X 1. Identify pin being touched
         * X 2. Build pin settings popover
         * 3. Show popover dynamically
         * 4. Save changes on touch outside
         * 5. Update UI to show new pin type, value, and name
         */

        // 2

        let selection = self.currentImageView.subviews.first(where: {child in
            guard (child is UIButton) else { return false }
            return child.frame.contains(touch)
        });

        if selection != nil {
            // Identify pin being touched
            let pinNumber = Int(((selection as! UIButton).titleLabel?.text)!)
            _ = pinNumber! % 2 == 0 // TODO: Use isEven

            // Update pin settings dialog
            self.pinSetupView.frame = CGRect(x: touch.x, y: touch.y, width: 128, height: 224)
            self.pinSetupView.isHidden = false
            self.pinSetupView.header.text = "Pin #\(pinNumber!)"


        } else {
            // Case where nothings selected
            self.pinSetupView.isHidden = true
        }

        // View gets reused
        self.currentImageView.addSubview(pinSetupView)
    }

}
