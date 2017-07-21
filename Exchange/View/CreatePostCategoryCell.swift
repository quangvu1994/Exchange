//
//  CreatePostCategoryCell.swift
//  Exchange
//
//  Created by Quang Vu on 7/7/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class CreatePostCategoryCell: UITableViewCell, PostInformationHandler {
    
    @IBOutlet weak var categoryName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func getInformation() -> String? {
        if categoryName.text == "" {
            return nil
        }

        return categoryName.text
    }
    
    func resetInformation() {
        self.categoryName.text = ""
    }
}
