//
//  ItemImageCell.swift
//  Exchange
//
//  Created by Quang Vu on 7/28/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class ItemImageCell: UITableViewCell, UIScrollViewDelegate {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var itemScrollView: UIScrollView!
    var post: Post?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        itemScrollView.delegate = self
        pageControl.numberOfPages = 2
        pageControl.currentPage = 0
        self.bringSubview(toFront: pageControl)
    }
    
    
    func createImageSlides(post: Post) -> [ItemSlide] {
        let slide: ItemSlide = Bundle.main.loadNibNamed("ItemSlide", owner: self, options: nil)?.first as! ItemSlide
        let slide2: ItemSlide = Bundle.main.loadNibNamed("ItemSlide", owner: self, options: nil)?.first as! ItemSlide
        
        let imageURL = URL(string: post.imageURL)
        slide.itemImage.kf.setImage(with: imageURL)
        slide2.itemImage.kf.setImage(with: imageURL)
        
        return [slide, slide2]
    }
    
    func setupSlide(slide: [ItemSlide]) {
        // Initialize the size of our scroll view and its content
        itemScrollView.frame = CGRect(x: 0, y: 0, width: itemScrollView.frame.width, height: itemScrollView.frame.height/2)
        itemScrollView.contentSize = CGSize(width: itemScrollView.frame.width, height: itemScrollView.frame.height)
        // Add the slide to the scroll view
        for i in 0..<slide.count {
            slide[i].frame = CGRect(x: 0, y: 0, width: itemScrollView.frame.width * CGFloat(i), height: itemScrollView.frame.height)
            itemScrollView.addSubview(slide[i])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(itemScrollView.contentOffset.x/itemScrollView.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }

}
