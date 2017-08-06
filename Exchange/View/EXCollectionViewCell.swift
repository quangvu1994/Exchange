//
//  EXCollectionViewCell.swift
//  Exchange
//
//  Created by Quang Vu on 7/13/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

protocol ImageSelectHandler: class {
    func storeSelectedImages(for selectedCell: EXCollectionViewCell)
}

class EXCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var checkMark: UIImageView!
    var imageSelected = false
    var index: Int?
    weak var delegate: ImageSelectHandler?

    func toggleSelectedCheckmark() {
        if imageSelected {
            itemImage.alpha = 1
            checkMark.isHidden = true
            imageSelected = false
        }else {
            itemImage.alpha = 0.5
            checkMark.isHidden = false
            imageSelected = true
        }
    }
    
    func addTapGesture(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EXCollectionViewCell.callDelegate))
        
        itemImage.isUserInteractionEnabled = true
        itemImage.addGestureRecognizer(tap)
    }
    
    func callDelegate() {
        guard let delegate = delegate else {
            return
        }
        
        delegate.storeSelectedImages(for: self)
    }
}




