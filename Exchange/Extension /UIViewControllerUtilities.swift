//
//  UIViewControllerUtilities.swift
//  Exchange
//
//  Created by Quang Vu on 7/7/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func hideKeyboard() {
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
}
