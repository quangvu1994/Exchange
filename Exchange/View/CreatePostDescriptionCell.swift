//
//  CreatePostDescriptionCell.swift
//  Exchange
//
//  Created by Quang Vu on 7/7/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class CreatePostDescriptionCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    var placeHolder: String?
    var view: UIView?
    
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

        if let _ = view {
            animateViewMoving(up: true, moveValue: 120)
        }
        if descriptionText.textColor == UIColor.lightGray {
            descriptionText.text = ""
            descriptionText.textColor = UIColor.darkGray
        }
    }
    
    func textViewDidEndEditing(_ textField: UITextView) {
        if let _ = view {
            animateViewMoving(up: false, moveValue: 120)
        }
        if descriptionText.text == "" {
            descriptionText.text = placeHolder!
            descriptionText.textColor = UIColor.lightGray
        }
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration: TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view!.frame = self.view!.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    func getInformation() -> String? {
        if descriptionText.text == "" || descriptionText.textColor == UIColor.lightGray {
            return nil
        }
        return descriptionText.text
    }
    
    func resetInformation() {
        descriptionText.text = placeHolder!
        descriptionText.textColor = UIColor.lightGray
    }
}
