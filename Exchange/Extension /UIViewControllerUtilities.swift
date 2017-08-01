//
//  UIViewControllerUtilities.swift
//  Exchange
//
//  Created by Quang Vu on 7/7/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /**
     Add a tap gesture to any UIViewController. The action is to hide the keyboard when tapping on the view itself
    */
    func hideKeyboardOnTap() {
        // Looking for a tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        
        // Do not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        // Add the behavior
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func displayWarningMessage(message: String){
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
