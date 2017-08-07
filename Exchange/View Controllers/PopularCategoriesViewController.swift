//
//  PopularCategoriesViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/7/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class PopularCategoriesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var categoryList = [
        "Fashion", "Shoes",
        "Beauty", "Electronic", "Room Essential",
        "Books", "Others"
    ]
    
    var imageList = [
        "Fashion", "Shoes",
        "Beauty", "Electronic", "RoomEssential",
        "Books", "Others"
    ]
    
    var compressImages = [UIImage?]()
    
    var smallestFontSize: CGFloat = 20.0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        // Compress all images
        for image in imageList {
            compressImages.append(self.resizeImage(image: UIImage(named: image)!))
        }
    }
    
    func configureTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let categoryIndex = sender as? Int else {
            fatalError("Unrecognized index")
        }
        
        if let identifier = segue.identifier {
            if identifier == "showCategoryDetail" {
                let destinationView = segue.destination as! MarketplaceViewController
                destinationView.category = categoryList[categoryIndex]
            }
        }
    }
    
    @IBAction func unwindToPopularCategory(_ sender: UIStoryboardSegue) {
        // Do nothing
    }
}

extension PopularCategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreCategoryCell", for: indexPath) as! ExploreCategoryCell
        cell.index = indexPath.row
        cell.delegate = self
        cell.addOpenCategoryGesture()
        cell.categoryName.text = categoryList[indexPath.row]
        cell.categoryBackgroundView.image = compressImages[indexPath.row]

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    // Dynamically set the height of each row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func resizeImage(image: UIImage) -> UIImage? {
        
        var actualHeight = image.size.height
        var actualWidth = image.size.width
        let maxHeight: CGFloat = 600.0
        let maxWidth: CGFloat = 800.0
        var imgRatio = actualWidth/actualHeight
        let maxRatio = maxWidth/maxHeight
        let compressionQuality: CGFloat = 0.1
        if (actualHeight > maxHeight || actualWidth > maxWidth){
            if(imgRatio < maxRatio){
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio){
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            }
            else{
                actualHeight = maxHeight;
                actualWidth = maxWidth;
            }
        }

        UIGraphicsBeginImageContext(CGSize(width: actualWidth, height: actualHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: actualWidth, height: actualHeight))
        
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext(),
            let compressedImage = UIImageJPEGRepresentation(newImage, compressionQuality) else {
            return nil
        }
        UIGraphicsEndImageContext()
        
        return UIImage(data: compressedImage)
    }
}

extension PopularCategoriesViewController: DisplayItemDetailHandler {
    
    func displayWithIndex(index: Int) {
        self.performSegue(withIdentifier: "showCategoryDetail", sender: index)
    }
    
    func displayWithFullInfo(imageURL: String, itemDescription: String, itemTitle: String) {
        // Don't need this
    }
}
