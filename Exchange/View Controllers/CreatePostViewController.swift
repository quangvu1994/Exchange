//
//  CreatePostViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/7/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import Kingfisher

protocol PostInformationHandler: class {
    func getInformation() -> String?
    
    func resetInformation()
}

class CreatePostViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var actionButton: UIButton!
    
    var currentPost: Post?
    var scenario: EXScenarios = .post
    
    weak var postTitleDelegate: PostInformationHandler?
    weak var postDescriptionDelegate: PostInformationHandler?
    weak var postCategoryDelegate: PostInformationHandler?
    weak var postTradeLocationDelegate: PostInformationHandler?
    
    var photoHelper = EXPhotoHelper()
    var category: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actionButton.layer.cornerRadius = 3
        tableView.tableFooterView = UIView()
        hideKeyboardOnTap()
        // Push view up when keyboard shows up
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        switch scenario {
        case .edit:
            if let currItem = currentPost {
                if !currItem.requestedBy.isEmpty {
                    actionButton.alpha = 0.5
                    actionButton.setTitle("In Exchange", for: .normal)
                } else {
                    actionButton.setTitle("Save Changes", for: .normal)
                }
            }
            
        case .exchange:
            // If the user has already requested this item, change the text
            if let currItem = currentPost,
                let _ = currItem.requestedBy["\(User.currentUser.uid)"] {
                actionButton.alpha = 0.5
                actionButton.setTitle("In Exchange", for: .normal)
            } else {
                actionButton.setTitle("Exchange Item", for: .normal)
            }

        default:
            actionButton.setTitle("Post Item", for: .normal)
        }
    }

    
    @IBAction func openPhotoHelper(_ sender: UIButton) {
        photoHelper.presentActionSheet(from: self)
    }
    
    @IBAction func performAction(_ sender: UIButton) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        switch scenario {
        case .edit:
            if actionButton.titleLabel?.text == "In Exchange" {
                let alertController = UIAlertController(title: nil, message: "All exchange requests contain this item need to be finalized before you can edit this item", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)

            } else {
                print("Edit")
            }
            UIApplication.shared.endIgnoringInteractionEvents()
        case .exchange:
            if actionButton.titleLabel?.text == "In Exchange" {
                let alertController = UIAlertController(title: nil, message: "You have already sent a request for this item. You can review your request under 'Outgoing Request' tab in your profile", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.performSegue(withIdentifier: "Exchange Sequence", sender: nil)
            }
            UIApplication.shared.endIgnoringInteractionEvents()
            
        default:
            guard let selectedImage = photoHelper.selectedImage,
                let postTitle = postTitleDelegate?.getInformation(),
                let postDescription = postDescriptionDelegate?.getInformation(),
                let postCategory = postCategoryDelegate?.getInformation(),
                let tradeLocation = postTradeLocationDelegate?.getInformation()
                else {
                    UIApplication.shared.endIgnoringInteractionEvents()
                    // Display an alert if user fail to fill out the required info
                    self.displayWarningMessage(message: "Please fill out all information")
                    return
            }
            
            PostService.writePostImageToFIRStorage(selectedImage, completion: { [weak self] (downloadURL) in
                guard let downloadURL = downloadURL else {
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self?.displayWarningMessage(message: "Unable to upload image, please try posting again")
                    return
                }
                
                let imageHeight = selectedImage.aspectHeight
                let post = Post(imageURL: downloadURL, imageHeight: imageHeight)
                post.postTitle = postTitle
                post.postDescription = postDescription
                post.postCategory = postCategory
                post.tradeLocation = tradeLocation
                
                PostService.writePostToFIRDatabase(for: post, completion: { [weak self] (completed) in
                    if completed {
                        // Clear everything in the table view
                        self?.photoHelper.selectedImage = nil
                        self?.postTitleDelegate?.resetInformation()
                        self?.postDescriptionDelegate?.resetInformation()
                        self?.postCategoryDelegate?.resetInformation()
                        self?.postTradeLocationDelegate?.resetInformation()
                        self?.tableView.reloadData()
                        self?.performSegue(withIdentifier: "showMarketplace", sender: post.postCategory)
                    }else {
                        self?.displayWarningMessage(message: "Unable to upload the post, please try posting again")
                    }
                    UIApplication.shared.endIgnoringInteractionEvents()
                })
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "Exchange Sequence" {
                let navControllerDestination = segue.destination as! UINavigationController
                let viewControllerDestination = navControllerDestination.viewControllers.first as! ExchangeSequenceViewController
                viewControllerDestination.posterItems.append(currentPost!)
                
            } else {
                let marketplaceView = segue.destination as! MarketplaceViewController
                guard let category = sender as? String else {
                    marketplaceView.category = "others"
                    return
                }
                marketplaceView.category = category
            }
        }
    }

    @IBAction func unwindFromCategorySelection(_ sender: UIStoryboardSegue) {
        // Update the category cell
        let indexPath = IndexPath(row: 3, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! CreatePostCategoryCell
        cell.categoryName.text = self.category
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

extension CreatePostViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CameraCell", for: indexPath) as! CreatePostCameraCell
            
            // Possile memory issue
            photoHelper.completionHandler = { (selectedImage) in
                cell.postImage.image = selectedImage
            }
            
            if let currentPost = currentPost {
                let imageURL = URL(string: currentPost.imageURL)
                cell.postImage.kf.setImage(with: imageURL)
            } else {
                cell.postImage.image = photoHelper.selectedImage
            }
            
            if scenario == .exchange {
                cell.isUserInteractionEnabled = false
            }
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! CreatePostDescriptionCell

            cell.headerText.text = "Title"
            self.postTitleDelegate = cell
            cell.placeHolder = "Item Title"
            
            if let currentPost = currentPost {
                cell.descriptionText.text = currentPost.postTitle
            } else {
                if let text = postTitleDelegate?.getInformation() {
                    cell.descriptionText.text = text
                } else {
                    cell.descriptionText.textColor = UIColor.lightGray
                    cell.descriptionText.text = "Item Title"
                }
            }
            
            if scenario == .exchange {
                cell.isUserInteractionEnabled = false
            }
            return cell
    
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! CreatePostDescriptionCell
            
            self.postDescriptionDelegate = cell
            cell.headerText.text = "Description"
            cell.placeHolder = "Item Description"
            
            if let currentPost = currentPost {
                cell.descriptionText.text = currentPost.postDescription
            } else {
                if let text = postDescriptionDelegate?.getInformation() {
                    cell.descriptionText.text = text
                } else {
                    cell.descriptionText.textColor = UIColor.lightGray
                    cell.descriptionText.text = "Item Description"
                }
            }
            
            if scenario == .exchange {
                cell.isUserInteractionEnabled = false
            }
            return cell

        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CreatePostCategoryCell
            self.postCategoryDelegate = cell
            if let currentPost = currentPost {
                cell.categoryName.text = currentPost.postCategory
                self.category = currentPost.postCategory
                
            }else {
                if let text = postCategoryDelegate?.getInformation() {
                    cell.categoryName.text = text
                } else {
                    cell.categoryName.text = ""
                }
            }
            
            if scenario == .exchange {
                cell.accessoryType = .none
                cell.isUserInteractionEnabled = false
            }
            return cell
            
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! CreatePostDescriptionCell
            cell.headerText.text = "Trade Location"
            self.postTradeLocationDelegate = cell
            cell.placeHolder = "Where we'll meet"
            
            if let currentPost = currentPost {
                cell.descriptionText.text = currentPost.tradeLocation
            } else {
                if let text = postTradeLocationDelegate?.getInformation() {
                    cell.descriptionText.text = text
                } else {
                    cell.descriptionText.textColor = UIColor.lightGray
                    cell.descriptionText.text = "Where we'll meet"
                }
            }
            
            if scenario == .exchange {
                cell.isUserInteractionEnabled = false
            }
            return cell
            
        default:
            fatalError("Unable to locate the current row")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            if let currentPost = currentPost {
                return currentPost.imageHeight
            }
            return 200
        case 1:
            return 100
        case 2:
            return 150
        case 3:
            return 60
        case 4:
            return 150
        default:
            fatalError("Unable to locate the current row")
        }
    }
}
