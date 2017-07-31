//
//  ItemDetailViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/27/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class ItemDetailViewController: UIViewController {
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var actionButton: UIButton!
    var scenario: EXScenarios = .exchange
    var post: Post?
    
    // Convert date to a formatted string
    let timestampFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        return dateFormatter
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "Exchange Sequence" {
                let navControllerDestination = segue.destination as! UINavigationController
                let viewControllerDestination = navControllerDestination.viewControllers.first as! ExchangeSequenceViewController
                viewControllerDestination.posterItems.append(post!)
            } else if identifier == "Edit Item" {
                let editView = segue.destination as! CreatePostViewController
                editView.currentPost = post
                editView.scenario = .edit
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
}

extension ItemDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
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
            view.bringSubview(toFront: cell.pageControl)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Poster Information", for: indexPath) as! PosterInformationCell
            
            cell.topLabel.text = post.poster.username
            cell.bottomLabel.text = timestampFormatter.string(from: post.creationDate)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Item Information", for: indexPath) as! ItemInfomationCell
            cell.titleLabel.text = post.postTitle
            cell.detailText.text = post.postDescription
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Category Cell", for: indexPath) as! ItemCategoryCell
            cell.categoryLabel.text = post.postCategory
            return cell
        case 4:
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
            return view.frame.height/2
        case 1:
            return 80
        case 2:
            return 140
        case 3:
            return 80
        case 4:
            return 140
        default:
            fatalError("Unrecognized index path row")
        }
    }
}
