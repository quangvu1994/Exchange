//
//  CreatePostCameraCell.swift
//  Exchange
//
//  Created by Quang Vu on 7/7/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class CreatePostCameraCell: UITableViewCell {
    
    @IBOutlet weak var firstImage: UIImageView!
    @IBOutlet weak var secondImage: UIImageView!
    @IBOutlet weak var thirdImage: UIImageView!
    @IBOutlet weak var fourthImage: UIImageView!
    var firstImageSet = false
    var secondImageSet = false
    var thirdImageSet = false
    var fourthImageSet = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        firstImage.isUserInteractionEnabled = true
        firstImage.tag = 0
        secondImage.isUserInteractionEnabled = true
        secondImage.tag = 1
        thirdImage.isUserInteractionEnabled = true
        thirdImage.tag = 2
        fourthImage.isUserInteractionEnabled = true
        fourthImage.tag = 3 
    }
    
    func getImageInformation() -> [UIImage]? {
        var imageList = [UIImage]()
        guard let firstImage = firstImage.image,
            let secondImage = secondImage.image,
            let thirdImage = thirdImage.image,
            let fourthImage = fourthImage.image else {return nil}
        
        if firstImageSet {
            imageList.append(firstImage)
        }
        if secondImageSet {
            imageList.append(secondImage)
        }
        if thirdImageSet {
            imageList.append(thirdImage)
        }
        if fourthImageSet {
            imageList.append(fourthImage)
        }
        
        if imageList.isEmpty {
            return nil
        } else {
            return imageList
        }
    }
}
