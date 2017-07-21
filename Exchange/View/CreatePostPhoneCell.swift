//
//  CreatePostPhoneCell.swift
//  Exchange
//
//  Created by Quang Vu on 7/21/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class CreatePostPhoneCell: UITableViewCell, PostInformationHandler, UITextFieldDelegate {

    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        phoneTextField.delegate = self
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(string == "\n") {
            textField.resignFirstResponder()
            return false
        }
        
        let maxLength = 10
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= maxLength
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if phoneTextField.textColor == UIColor.lightGray {
            phoneTextField.text = ""
            phoneTextField.textColor = UIColor.black
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let number = phoneTextField.text else {
            return
        }

        if number == "" || number.characters.count != 10 {
            phoneTextField.text = phoneTextField.placeholder
            phoneTextField.textColor = UIColor.lightGray
        }
    }
    
    func getInformation() -> String? {
        if phoneTextField.text == "" || phoneTextField.textColor == UIColor.lightGray {
            return nil
        }
        return phoneTextField.text
    }
    
    func resetInformation() {
        phoneTextField.text = phoneTextField.placeholder
        phoneTextField.textColor = UIColor.lightGray
    }

}
