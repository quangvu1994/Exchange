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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var post = [Post]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var filteredData = [Post]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var isSearching = false
    var category: String?
    let searchBar = UISearchBar()
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MarketplaceViewController.hideSearchKeyboard)))
        searchBar.delegate = self
        addSearchBarOnNavigationController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.startAnimating()
        // fetch all post
        PostService.fetchPost(completionHandler: { [weak self] (allPosts) in
            guard let category = self?.category else {
                self?.post = allPosts
                self?.activityIndicator.stopAnimating()
                return
            }
            
            // Filter by category and availability
            self?.post = allPosts.filter {
                $0.postCategory.lowercased() == category.lowercased() && $0.availability
            }
            
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: (self?.view.bounds.width)!, height: (self?.view.bounds.height)!))
            emptyLabel.textAlignment = .center
            emptyLabel.font = UIFont(name: "Futura", size: 16)
            emptyLabel.textColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
            emptyLabel.numberOfLines = 2
        
            if self?.post.count == 0 {
                emptyLabel.text = "Sorry, there is no item listed for this category yet"
                self?.collectionView.backgroundView = emptyLabel
            } else {
                self?.collectionView.backgroundView = nil
            }
            self?.activityIndicator.stopAnimating()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "displayItemDetail" {
                guard let index = sender as? Int else {
                    return
                }
                
                let viewControllerDestination = segue.destination as! ItemDetailViewController
                if isSearching {
                    viewControllerDestination.post = filteredData[index]
                } else {
                    viewControllerDestination.post = post[index]
                }
            }
        }
    }

    func hideSearchKeyboard() {
        searchBar.endEditing(true)
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            collectionView.reloadData()
            collectionView.backgroundView = nil
        } else {
            isSearching = true
            filteredData = post.filter {
                $0.postTitle.lowercased().contains((searchBar.text?.lowercased())!) || $0.postDescription.lowercased().contains((searchBar.text?.lowercased())!)
            }
            
            if filteredData.count == 0 {
                let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
                emptyLabel.textAlignment = .center
                emptyLabel.font = UIFont(name: "Futura", size: 16)
                emptyLabel.textColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
                emptyLabel.numberOfLines = 2
                emptyLabel.text = "No matched result"
                collectionView.backgroundView = emptyLabel
            } else {
                collectionView.backgroundView = nil
            }
        }
    }
    
    @IBAction func unwindFromItemDetail(_ sender: UIStoryboardSegue) {
        print("Unwinded")
    }
}

extension MarketplaceViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching {
            return filteredData.count
        }
        
        return post.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostThumbImageCell", for: indexPath) as! PostThumbImageCell

        if isSearching {
            let imageURL = URL(string: filteredData[indexPath.row].imagesURL[0])
            cell.postImage.kf.setImage(with: imageURL)
        } else {
            let imageURL = URL(string: post[indexPath.row].imagesURL[0])
            cell.postImage.kf.setImage(with: imageURL)
        }
        
        cell.delegate = self
        cell.gestureDisplayingItemDetailWithIndex()
        cell.index = indexPath.row
        
        // Observe the availability of this item
        let itemRef = Database.database().reference().child("allItems/\(post[indexPath.row].key!)/availability")
        itemRef.observe(.value, with: { (snapshot) in
            guard let availability = snapshot.value as? Bool else {
                return
            }
            
            if !availability {
                cell.itemLabel.isHidden = false
            } else {
                cell.itemLabel.isHidden = true
            }
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionElementKindSectionHeader else {
            fatalError("Unexpected element kind.")
        }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MarketplaceHeaderView", for: indexPath) as! MarketplaceHeaderView
        if let categoryName = category {
            headerView.categoryName.text = categoryName
        } else {
            headerView.categoryName.text = "All Items"
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
    
    func displayWithIndex(index: Int) {
        self.performSegue(withIdentifier: "displayItemDetail", sender: index)
    }

    func displayWithFullInfo(imageURL: String, itemDescription: String, itemTitle: String) {
        // Not needed here
    }
    
}
