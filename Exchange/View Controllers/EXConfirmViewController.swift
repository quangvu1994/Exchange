//
//  EXConfirmViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/13/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import FirebaseDatabase

class EXConfirmViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var selectedItems = [Post]()
    var exchangeItem: Post?
    weak var messageDelegate: PostInformationRetriever?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        hideKeyboardOnTap()
    }
    
    @IBAction func sendRequest(_ sender: UIButton) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        guard let exchangeItem = exchangeItem,
            let exchangeItemKey = exchangeItem.key,
            let messageDelegate = messageDelegate else {
                UIApplication.shared.endIgnoringInteractionEvents()
                // Display an alert if user fail to fill out the required info
                let alertController = UIAlertController(title: nil, message: "Unable to send request. Please try again", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                return
        }
        // Write the request to our database
        let request = Request(arrayOfYoursItems: selectedItems, theirItem: exchangeItem)
        request.message = messageDelegate.getInformation()!
        let requestRef = Database.database().reference().child("Outgoing Request").child(User.currentUser.uid).child(exchangeItemKey)
        RequestService.writeNewRequest(at: requestRef, for: request)
        let alertController = UIAlertController(title: nil, message: "Request sent!", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            self.performSegue(withIdentifier: "Finish Exchange Sequence", sender: self)
        })
        
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        UIApplication.shared.endIgnoringInteractionEvents()
    }

}

extension EXConfirmViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Image Cell", for: indexPath) as! EXTableImageCell
            if let exchangeItem = exchangeItem {
                let imageURL = URL(string: exchangeItem.imageURL)
                cell.requestItemImage.kf.setImage(with: imageURL)
            }
            
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Description Cell", for: indexPath) as! EXTableDescriptionCell
            cell.titleText.text = "Exchange with"
            cell.descriptionText.text = selectedItems.map { $0.postTitle }.joined(separator: ", ")
            cell.descriptionText.isEditable = false
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Description Cell", for: indexPath) as! EXTableDescriptionCell
            cell.titleText.text = "Say something to the owner"
            cell.descriptionText.textColor = UIColor.lightGray
            cell.descriptionText.text = "Your message"
            cell.placeHolder = "Your message"
            messageDelegate = cell
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Button Cell", for: indexPath)
            return cell
        default:
            fatalError("Unrecognize index path row")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            guard let exchangeItem = exchangeItem else {
                return 200
            }
            return exchangeItem.imageHeight
        case 1:
            return 100
        case 2:
            return 150
        case 3:
            return 80
        default:
            fatalError("Unrecognize index path row")
        }
    }
}
