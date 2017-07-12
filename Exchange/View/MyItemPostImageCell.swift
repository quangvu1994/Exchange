//
//  MyItemPostImageCell.swift
//  Exchange
//
//  Created by Quang Vu on 7/10/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

protocol DisplayItemDetailHandler {
    func display()
}

class MyItemPostImageCell: UICollectionViewCell {
    
    @IBOutlet weak var postImage: UIImageView!
    var delegate: DisplayItemDetailHandler?
    
    func displayItemDetail() {
        guard let _ = delegate else {
            print("No delegation is set to handle displaying item detail")
            return
        }
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyItemPostImageCell.callDelegateMethod))
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(tap)
    }
    
    func callDelegateMethod() {
        delegate?.display()
    }
}
