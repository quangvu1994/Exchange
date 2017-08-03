//
//  PostThumbImageCell.swift
//  Exchange
//
//  Created by Quang Vu on 7/7/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class PostThumbImageCell: UICollectionViewCell {
    
    @IBOutlet weak var postImage: UIImageView!
    var index: Int?
    weak var delegate: DisplayItemDetailHandler?
    
    func gestureDisplayingItemDetailWithIndex() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostThumbImageCell.displayDetailWithIndex))
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
}
