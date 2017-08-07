//
//  ItemDetailViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/27/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ItemDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var flaggingButton: UIBarButtonItem!
    var scenario: EXScenarios = .exchange
    var post: Post?
    
    // Convert date to a formatted string
    let timestampFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, YYYY"
        
        return dateFormatter
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        // Make sure that you can't report yourself
        if post?.poster.uid == User.currentUser.uid {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actionButton.layer.masksToBounds = true
        actionButton.layer.cornerRadius = 3
        // If the user has already requested this item, change the text
        guard let post = post else {
            return
        }
        
        switch post.poster.uid {
        case User.currentUser.uid:
            if !post.requestedBy.isEmpty {
                actionButton.alpha = 0.5
                actionButton.setTitle("In Exchange", for: .normal)
            } else {
                actionButton.setTitle("Edit Item", for: .normal)
            }
        default:
            if let _ = post.requestedBy["\(User.currentUser.uid)"] {
                actionButton.alpha = 0.5
                actionButton.setTitle("In Exchange", for: .normal)
            } else {
                actionButton.setTitle("Exchange Item", for: .normal)
            }
        }
        
        let itemRef = Database.database().reference().child("allItems/\(post.key!)/availability")
        itemRef.observe(.value, with: { [weak self] (snapshot) in
            guard let availability = snapshot.value as? Bool else {
                return
            }
            
            if !availability {
                self?.actionButton.alpha = 0.5
                self?.actionButton.setTitle("Item Sold", for: .normal)
                self?.actionButton.isUserInteractionEnabled = false
            }
        })
    }
    
    @IBAction func actionHandler(_ sender: UIButton) {
        guard let post = post else {
            return
        }
        UIApplication.shared.beginIgnoringInteractionEvents()
        switch post.poster.uid {
        case User.currentUser.uid:
            if actionButton.titleLabel?.text == "In Exchange" {
                let alertController = UIAlertController(title: nil, message: "All exchange requests contain this item need to be finalized before you can edit this item", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
                
            } else {
                self.performSegue(withIdentifier: "Edit Item", sender: nil)
            }
        default:
            if actionButton.titleLabel?.text == "In Exchange" {
                let alertController = UIAlertController(title: nil, message: "You have already sent a request for this item. You can review your request under 'Outgoing Request' tab in your profile", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.performSegue(withIdentifier: "Exchange Sequence", sender: nil)
            }
        }
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    /**
     Flagging post with inappropriate content
    */
    @IBAction func flaggingPost(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        let flagAction = UIAlertAction(title: "Report as Inappropriate", style: .default) { [weak self] _ in
            guard let post = self?.post else {
                return
            }
            
            PostService.flag(post)
            
            let okAlert = UIAlertController(title: nil, message: "The post has been flagged.", preferredStyle: .alert)
            okAlert.addAction(UIAlertAction(title: "Ok", style: .default))
            self?.present(okAlert, animated: true)
        }
        
        alertController.addAction(flagAction)
        
        // Add cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Prenset action sheet
        present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "Exchange Sequence" {
                let navControllerDestination = segue.destination as! UINavigationController
                let viewControllerDestination = navControllerDestination.viewControllers.first as! ExchangeSequenceViewController
                viewControllerDestination.originalItem = post
            } else if identifier == "Edit Item" {
                let editView = segue.destination as! CreatePostViewController
                editView.currentPost = post
                editView.scenario = .edit
            } else if identifier == "Open User Store" {
                guard let user = sender as? User else {
                    return
                }
                let viewControllerDestination = segue.destination as! MyItemViewController
                // Safe to force unwrap here
                viewControllerDestination.user = user
            }
        }
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        switch scenario {
        case .edit:
            self.performSegue(withIdentifier: "Personal Item Detail", sender: nil)
        default:
            self.performSegue(withIdentifier: "Item Detail", sender: nil)
        }
    }
    
    @IBAction func unwindFromExchangeSequence(_ sender: UIStoryboardSegue) {
        if let identifier = sender.identifier {
            if identifier == "Finish Exchange Sequence" {
                actionButton.alpha = 0.5
                actionButton.setTitle("In Exchange", for: .normal)
            }
        }
    }
    
    func segueToUserStore() {
        // Fetch user info 
        UserService.retrieveUser((post?.poster.uid)!, completion: { [weak self] (userFromFIR) in
            guard let user = userFromFIR else {
                self?.displayWarningMessage(message: "Unable to retrieve this user information, please check your network")
                return
            }
            self?.performSegue(withIdentifier: "Open User Store", sender: user)
        })
    }
}

extension ItemDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let post = post else {
            fatalError("No post found, can't display information")
        }
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Image Slide Cell", for: indexPath) as! ItemImageCell
            let slide = cell.createImageSlides(post: post)
            cell.setupSlide(slide: slide, view: view)
            cell.pageControl.numberOfPages = post.imagesURL.count
            cell.pageControl.currentPage = 0
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Poster Information", for: indexPath) as! PosterInformationCell
            
            cell.topLabel.text = post.poster.username
            cell.topLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ItemDetailViewController.segueToUserStore)))
            cell.bottomLabel.text = timestampFormatter.string(from: post.creationDate)
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Item Information", for: indexPath) as! ItemInfomationCell
            cell.titleLabel.text = post.postTitle
            cell.detailText.text = post.postDescription
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Item Information", for: indexPath) as! ItemInfomationCell
            cell.titleLabel.text = "Wish List"
            cell.detailText.text = post.wishList
            return cell
            
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Category Cell", for: indexPath) as! ItemCategoryCell
            cell.categoryLabel.text = post.postCategory
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Item Information", for: indexPath) as! ItemInfomationCell
            cell.titleLabel.text = "Trade Location"
            cell.detailText.text = post.tradeLocation
            return cell
        default:
            fatalError("Unrecognized index path row")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return view.frame.height*4/7
        case 1:
            return 80
        case 2:
            return 140
        case 3:
            return 140
        case 4:
            return 80
        case 5:
            return 140
        default:
            fatalError("Unrecognized index path row")
        }
    }
}
