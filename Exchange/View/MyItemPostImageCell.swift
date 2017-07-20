//
//  MyItemPostImageCell.swift
//  Exchange
//
//  Created by Quang Vu on 7/10/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

protocol DisplayItemDetailHandler: class {
    func display(index: Int)
}

class MyItemPostImageCell: UICollectionViewCell {
    
    var index: Int?
    @IBOutlet weak var postImage: UIImageView!
    weak var delegate: DisplayItemDetailHandler?
    func addTapGestureToDisplayItemDetail() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyItemPostImageCell.callDelegateMethod))
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(tap)
    }
    
    func callDelegateMethod() {
        guard let delegate = delegate,
            let index = index else {
                return
        }
        delegate.display(index: index)
    }
}
