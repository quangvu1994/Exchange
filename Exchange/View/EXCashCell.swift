//
//  EXCashCell.swift
//  Exchange
//
//  Created by Quang Vu on 7/31/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class EXCashCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var cashSwitch: UISwitch!
    @IBOutlet weak var amountField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        amountField.isEnabled = false
        amountField.delegate = self
        setAmountFieldBorder()
    }
    
    @IBAction func addCashToggle(_ sender: Any) {
        amountField.isEnabled = !amountField.isEnabled
        if amountField.isEnabled {
            amountField.becomeFirstResponder()
        } else {
            amountField.resignFirstResponder()
        }
        amountField.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if amountField.text != "" {
            amountField.text = "$" + amountField.text!
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        amountField.text = ""
    }
    
    func setAmountFieldBorder() {
        self.amountField.borderStyle = .none
        self.amountField.layer.backgroundColor = UIColor.white.cgColor
        
        self.amountField.layer.masksToBounds = false
        self.amountField.layer.shadowColor = UIColor.gray.cgColor
        self.amountField.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.amountField.layer.shadowOpacity = 1.0
        self.amountField.layer.shadowRadius = 0
    }
    
}
