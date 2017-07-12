//
//  UICollectionViewUtilities.swift
//  Exchange
//
//  Created by Quang Vu on 7/11/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

extension UICollectionReusableView {

    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UICollectionReusableView.dismissKeyboard))
        tap.cancelsTouchesInView = false
        
        self.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        self.endEditing(true)
    }
}
