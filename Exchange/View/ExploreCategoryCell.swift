//
//  ExploreCategoryCell.swift
//  Exchange
//
//  Created by Quang Vu on 7/6/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class ExploreCategoryCell: UITableViewCell {

    @IBOutlet weak var categoryBackgroundView: UIImageView!
    @IBOutlet weak var overlapCategoryView: UIView!
    @IBOutlet weak var categoryName: UILabel!
    var delegate: DisplayItemDetailHandler?
    var index: Int?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func addOpenCategoryGesture() {
        let tapOnBackground: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ExploreCategoryCell.openDetail))
        let tapOnFrontView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ExploreCategoryCell.openDetail))
        categoryBackgroundView.isUserInteractionEnabled = true
        categoryBackgroundView.addGestureRecognizer(tapOnBackground)
        overlapCategoryView.addGestureRecognizer(tapOnFrontView)
    }
    
    func openDetail() {
        guard let delegate = delegate,
            let index = index else {
            return
        }
        
        delegate.display(index: index)
    }
}
