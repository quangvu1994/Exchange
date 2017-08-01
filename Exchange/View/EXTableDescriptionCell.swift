//
//  EXTableDescriptionCell.swift
//  Exchange
//
//  Created by Quang Vu on 7/14/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class EXTableDescriptionCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var titleText: UILabel!
    var view: UIView?
    
    var placeHolder: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionText.delegate = self
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let _ = view {
            animateViewMoving(up: true, moveValue: 200)
        }
        if descriptionText.textColor == UIColor.lightGray {
            descriptionText.text = ""
            descriptionText.textColor = UIColor.black
        }

    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let _ = view {
            animateViewMoving(up: false, moveValue: 200)
        }
        if descriptionText.text == "" {
            descriptionText.text = placeHolder!
            descriptionText.textColor = UIColor.lightGray
        }
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.2
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view!.frame = self.view!.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }

    func getInformation() -> String? {
        if descriptionText.textColor == UIColor.lightGray {
            return ""
        }
        return descriptionText.text
    }
    
    func resetInformation() {
        descriptionText.text = placeHolder!
        descriptionText.textColor = UIColor.lightGray
    }
}
