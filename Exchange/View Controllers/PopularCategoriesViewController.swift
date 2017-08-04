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
        ("Room Essential", "RoomEssential.png"),
        ("Clothes", "Clothes.png"),
        ("Electronic", "Electronic.png"),
        ("Books", "Book.png")
    ]
    
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
                destinationView.category = categoryList[categoryIndex].0
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
        let backgroundImage = UIImage(named: categoryList[indexPath.row].1)
        cell.categoryBackgroundView.image = resizeImage(image: backgroundImage!, newWidth: 800)
        cell.categoryName.text = categoryList[indexPath.row].0
        cell.index = indexPath.row
        cell.delegate = self
        cell.addOpenCategoryGesture()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    // Dynamically set the height of each row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
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
