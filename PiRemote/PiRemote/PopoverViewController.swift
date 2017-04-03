//
//  PopoverFactory
//  PiRemote
//
//  Created by Muhammad Martinez on 4/1/17.
//  Copyright © 2017 JLL Consulting. All rights reserved.
//

import UIKit

// Handles events that occur in popovers using NSNotificationCenter
class PopoverViewController: UIViewController {

    static let storyboardName = "DeviceSetup"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Loads appropriate diagram if needed
        if self.title == "Pinout Diagram" {
            _buildContentDiagram()
        }
    }

    // Local Functions
    @IBAction func onApply(_ sender: UIBarButtonItem) {
        // TODO: Pass selected layout
        NotificationCenter.default.post(name: NotificationNames.apply, object: nil)
    }

    @IBAction func onClear(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: NotificationNames.clear, object: nil)
    }

    @IBAction func onDismiss(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onSave(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: NotificationNames.save, object: nil)
    }

    func _buildContentDiagram() {
        let diagram = UIImage(named: getFilePathToPinDiagram())

        // TODO: Update subviews based on picker value in DeviceSetup
        let imageView = self.view.subviews.filter({vw in vw is UIImageView}).first as! UIImageView
        let label = self.view.subviews.filter({vw in vw is UILabel}).first as! UILabel

        // Order is important: resizes content after the image has been added to it.
        imageView.image = diagram
        imageView.contentMode = .scaleAspectFit

        label.text = "Raspberry Pi 3"
    }

    // Utility Functions
    static func buildContentLogin(source: AnyObject) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let content = storyboard.instantiateViewController(withIdentifier: "WEB_DIALOG")
        let contentSize = CGSize(width: 320, height: 320)
        return buildPopover(source: source, content: content, contentSize: contentSize, sourceRect: nil)
    }

    static func buildPopover(source: AnyObject, content: UIViewController, contentSize: CGSize, sourceRect: CGRect?) -> UIViewController {
        // Display like an alert
        content.modalPresentationStyle = .popover
        content.modalTransitionStyle = .coverVertical
        content.preferredContentSize = contentSize

        // Modifies the controller which will contain content
        let popover = content.popoverPresentationController
        popover?.delegate = source as? UIPopoverPresentationControllerDelegate
        popover?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)  // Hides arrow
        popover?.sourceView = (source as! UIViewController).view

        // Positions in center of parent
        popover?.sourceRect = sourceRect != nil ? sourceRect! : content.view.bounds

        return content
    }

    // Only supports Raspberry Pi 3
    func getFilePathToPinDiagram() -> String {
        return PinGuideFilePaths.rPi3
    }
}
