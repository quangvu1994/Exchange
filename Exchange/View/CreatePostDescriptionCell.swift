//
//  CreatePostDescriptionCell.swift
//  Exchange
//
//  Created by Quang Vu on 7/7/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class CreatePostDescriptionCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var descriptionText: UITextView!
    var placeHolder: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionText.delegate = self
    }

    // Resign keyboard when press Enter or Return
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionText.textColor == UIColor.lightGray {
            descriptionText.text = ""
            descriptionText.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textField: UITextView) {
        if descriptionText.text.isEmpty {
            descriptionText.text = placeHolder!
            descriptionText.textColor = UIColor.lightGray
        }
    }

}
