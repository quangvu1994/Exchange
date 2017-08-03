//
//  MyItemHeaderView.swift
//  Exchange
//
//  Created by Quang Vu on 7/10/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MyItemHeaderView: UICollectionReusableView, UITextViewDelegate {
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var shopBriefDescription: UITextView!
    @IBOutlet weak var editButton: UIButton!
    var userID: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shopBriefDescription.delegate = self
    }
    @IBAction func editStoreDescription(_ sender: Any) {
        shopBriefDescription.isEditable = true
        shopBriefDescription.tintColor = UIColor.white
        shopBriefDescription.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        shopBriefDescription.isEditable = false
        // Save the changes
        guard let userID = userID else {
            return
        }
    
        Database.database().reference().child("users/\(userID)/storeDescription").setValue(shopBriefDescription.text!)
        // Update current user and our user default
        User.currentUser.storeDescription = shopBriefDescription.text!
        User.setCurrentUser(User.currentUser, writeToUserDefaults: true)
    }
}
