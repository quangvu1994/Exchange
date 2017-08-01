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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        itemScrollView.layer.zPosition = 2
        pageControl.layer.zPosition = 3
        itemScrollView.delegate = self
    }
    
    
    func createImageSlides(post: Post) -> [ItemSlide] {
        let itemSlide: [ItemSlide] = post.imagesURL.flatMap {
            let slide: ItemSlide = Bundle.main.loadNibNamed("ItemSlide", owner: self, options: nil)?.first as! ItemSlide
            let imageURL = URL(string: $0)
            slide.itemImage.kf.setImage(with: imageURL)
            return slide
        }
        
        return itemSlide
    }
    
    func setupSlide(slide: [ItemSlide], view: UIView) {
        // Initialize the size of our scroll view and its content
        itemScrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: itemScrollView.frame.height)
        itemScrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slide.count), height: itemScrollView.frame.height)
        itemScrollView.isPagingEnabled = true
        // Add the slide to the scroll view
        for i in 0..<slide.count {
            slide[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: itemScrollView.frame.height)
            itemScrollView.addSubview(slide[i])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(itemScrollView.contentOffset.x/itemScrollView.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }

}
