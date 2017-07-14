//
//  EXTableButtonCell.swift
//  Exchange
//
//  Created by Quang Vu on 7/14/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class EXTableButtonCell: UITableViewCell {

    @IBOutlet weak var sendRequestButton: UIButton!
    
    override func awakeFromNib() {
        sendRequestButton.layer.cornerRadius = 3
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func sendRequest(_ sender: UIButton) {
        print("Request sent")
    }

}
