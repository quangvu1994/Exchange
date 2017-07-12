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
    var delegate: DisplayItemDetailHandler?
    
    func addTapGestureToDisplayItemDetail() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostThumbImageCell.callDelegate))
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(tap)
    }
    
    func callDelegate() {
        guard let delegate = delegate,
            let index = index else {
            return
        }
        delegate.display(index: index)
    }
}
