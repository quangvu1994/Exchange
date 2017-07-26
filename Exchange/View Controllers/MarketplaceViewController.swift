//
//  MarketplaceViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/4/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Kingfisher

class MarketplaceViewController: UIViewController, UISearchBarDelegate {
    
    var post = [Post]() {
        didSet {
            collectionView.reloadData()
        }
    }
    var category: String?
    let searchBar = UISearchBar()
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        addSearchBarOnNavigationController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // fetch all post
        PostService.fetchPost(completionHandler: { [weak self] (allPosts) in
            guard let category = self?.category else {
                self?.post = allPosts
                return
            }
            
            // Filter by category and availability
            self?.post = allPosts.filter {
                $0.postCategory.lowercased() == category.lowercased() && $0.availability
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "displayItemDetail" {
                guard let index = sender as? Int else {
                    return
                }
                
                let viewControllerDestination = segue.destination as! CreatePostViewController
                viewControllerDestination.currentPost = post[index]
                viewControllerDestination.scenario = .exchange
            }
        }
    }
    
    func addSearchBarOnNavigationController() {
        searchBar.tintColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        self.navigationItem.titleView = searchBar
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = nil
        searchBar.showsCancelButton = false
    }
    
}

extension MarketplaceViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostThumbImageCell", for: indexPath) as! PostThumbImageCell
        let imageURL = URL(string: post[indexPath.row].imageURL)
        cell.postImage.kf.setImage(with: imageURL)
        cell.delegate = self
        cell.addTapGestureToDisplayItemDetail()
        cell.index = indexPath.row
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionElementKindSectionHeader else {
            fatalError("Unexpected element kind.")
        }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MarketplaceHeaderView", for: indexPath) as! MarketplaceHeaderView
        if let categoryName = category {
            headerView.categoryName.text = categoryName
        }
        return headerView
    }
}


extension MarketplaceViewController: UICollectionViewDelegateFlowLayout {
    
    // Set the size of each cell in the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 2
        let spacing: CGFloat = 3
        // 2 spaces multiply by the length of each space = total horizontal spacing
        let totalHorizontalSpacing = (columns - 1) * spacing
        
        // Total width - the horizontal spacing = total width of all columns
        // Divide by number of columns to find the width of one column
        let itemWidth = (collectionView.bounds.width - totalHorizontalSpacing) / columns
        // Instantiate a CGSize
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 3.0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
}

extension MarketplaceViewController: DisplayItemDetailHandler {
    
    func display(index: Int) {
        self.performSegue(withIdentifier: "displayItemDetail", sender: index)
    }
    
}
