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
    var exchangeItems = [Post]()
    weak var messageDelegate: PostInformationHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        hideKeyboardOnTap()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func sendRequest(_ sender: UIButton) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        guard let messageDelegate = messageDelegate else {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.displayWarningMessage(message: "Unable to send request, please try again")
                return
        }
        let requesterItemsRefList: [String] = selectedItems.flatMap { $0.key }
        let posterItemsRefList: [String] = exchangeItems.flatMap { $0.key }

        // Write the request to our database
        let request = Request(requester: User.currentUser, requesterItemsRefList: requesterItemsRefList, posterItemsRefList: posterItemsRefList)
        // Safe to force unwrap
        request.message = messageDelegate.getInformation()!
        RequestService.writeNewRequest(for: request, completionHandler: { [weak self](success) in
            if !success {
                self?.displayWarningMessage(message: "Unable to send request, please try again")
                return
            }
        })
        
        // Display successful dialog
        let alertController = UIAlertController(title: nil, message: "Your exchange request has been sent!", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            self.performSegue(withIdentifier: "Finish Exchange Sequence", sender: nil)
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
            return 150
        case 2:
            return 200
        case 3:
            return 80
        default:
            fatalError("Unrecognize index path row")
        }
    }
}
