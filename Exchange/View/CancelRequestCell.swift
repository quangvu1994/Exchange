//
//  CancelRequestCell.swift
//  Exchange
//
//  Created by Quang Vu on 8/6/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class CancelRequestCell: UITableViewCell {

    @IBOutlet weak var cancelButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.cornerRadius = 3
        cancelButton.layer.borderColor = UIColor(red: 210/255, green: 104/255, blue: 84/255, alpha: 1.0).cgColor
        cancelButton.layer.borderWidth = 1
    }
}
