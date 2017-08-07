//
//  RequestTableViewCell.swift
//  Exchange
//
//  Created by Quang Vu on 7/17/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class RequestTableViewCell: UITableViewCell {

    @IBOutlet weak var poster: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var briefDescription: UILabel!
    @IBOutlet weak var status: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        itemImage.layer.masksToBounds = true
        itemImage.layer.cornerRadius = 3
    }
    
    func setStatus(status: String) {
        self.status.text = status
        if status == "Accepted" {
            self.status.textColor = UIColor(red: 121/255, green: 189/255, blue: 143/255, alpha: 1.0)
        } else if status == "Rejected" {
            self.status.textColor = UIColor(red: 220/255, green: 53/255, blue: 34/255, alpha: 1.0)
        } else {
            self.status.textColor = UIColor(red: 79/255, green: 146/255, blue: 193/255, alpha: 1.0)
        }
    }

}
