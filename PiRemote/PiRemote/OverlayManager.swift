//
//  OverlayManager.swift
//  Voice
//
//  Created by Victor Anyirah on 1/21/16.
//  Copyright (c) 2016 Victor Anyirah. All rights reserved.
//

import UIKit

extension CGRect{
    init(_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat) {
        self.init(x:x,y:y,width:width,height:height)
    }
}


class OverlayManager: NSObject {



    
    static func createErrorOverlay(message: String) -> UIAlertController{
        return self.createActionOverlay(title:"Oh no!", withMessage: message)
    }
    
    static func createSucessOverlay(message: String) -> UIAlertController{
        return self.createActionOverlay(title: "Success", withMessage: message)
    }
    
    
    static func createLoadingSpinner(withMessage actionMessage: String = "Please wait...") -> UIAlertController{
        let alert = UIAlertController(title: nil, message: actionMessage, preferredStyle: .alert)
        
        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(5, 5, 50, 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        return alert
    }
    
    static func createAndStartAnimatingBasicLoadingSpinner() -> UIActivityIndicatorView {
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(5, 5, 50, 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        loadingIndicator.startAnimating();
        return loadingIndicator
    }
    
    static func createActionOverlay(title: String, withMessage actionMessage: String) -> UIAlertController{
        let alertController = UIAlertController(title: title, message: actionMessage, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        return alertController
    }
    
}
