//
//  MyItemPostImageCell.swift
//  Exchange
//
//  Created by Quang Vu on 7/10/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

protocol DisplayItemDetailHandler: class {
    func displayWithIndex(index: Int)
    func displayWithFullInfo(imageURL: String, itemDescription: String, itemTitle: String)
}

class MyItemPostImageCell: UICollectionViewCell {
    
    var index: Int?
    var itemImageURL: String?
    var itemDescription: String?
    var itemTitle: String?
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var imageLabel: UILabel!
    
    weak var delegate: DisplayItemDetailHandler?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageLabel.layer.masksToBounds = true
        imageLabel.layer.cornerRadius = 3
    }
    
    func gestureDisplayingItemDetailWithIndex() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyItemPostImageCell.displayDetailWithIndex))
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(tap)
    }
    
    func gestureDisplayingItemDetailWithInfo() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyItemPostImageCell.displayDetailWithInfo))
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(tap)
    }
    
    func displayDetailWithIndex() {
        guard let delegate = delegate,
            let index = index else {
                return
        }
        delegate.displayWithIndex(index: index)
    }
    
    func displayDetailWithInfo() {
        guard let delegate = delegate,
            let itemImageURL = itemImageURL,
            let itemDescription = itemDescription,
            let itemTitle = itemTitle else {
                return
        }
        delegate.displayWithFullInfo(imageURL: itemImageURL, itemDescription: itemDescription, itemTitle: itemTitle)
    }
}
