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
    var buttonIsSelected = false
    var index: Int?
    weak var delegate: ImageSelectHandler?
    
    override func awakeFromNib() {
        checkMark.isHidden = true
    }
    
    func toggleSelectedCheckmark() {
        if buttonIsSelected {
            checkMark.isHidden = true
            buttonIsSelected = false
        }else {
            checkMark.isHidden = false
            buttonIsSelected = true
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




