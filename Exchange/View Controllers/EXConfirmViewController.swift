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
    var requesterItems = [Post]()
    var posterItems = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        hideKeyboardOnTap()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func sendRequest(_ sender: UIButton) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! EXTableDescriptionCell
        
        // Write the request to our database
        let request = Request(requesterItems: requesterItems, posterItems: posterItems)
        // Safe to force unwrap
        request.message = cell.getInformation()!
        
        // NOTE: need dispatch group here
        RequestService.writeNewRequest(for: User.currentUser.uid, and: posterItems[0].poster.uid, with: request, completionHandler: { [weak self] (success) in
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
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Image Cell", for: indexPath) as! EXTableCollectionCell
            cell.itemList = requesterItems
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Trade For", for: indexPath)
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Image Cell", for: indexPath) as! EXTableCollectionCell
            cell.itemList = posterItems
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cash Cell", for: indexPath) as! EXCashCell
            
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Description Cell", for: indexPath) as! EXTableDescriptionCell
            cell.titleText.text = "Say something to the owner"
            cell.descriptionText.textColor = UIColor.lightGray
            cell.descriptionText.text = "Your message"
            cell.placeHolder = "Your message"
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Button Cell", for: indexPath)
            return cell
        default:
            fatalError("Unrecognize index path row")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 150
        case 1:
            return 40
        case 2:
            return 150
        case 3:
            return 80
        case 4:
            return 200
        case 5:
            return 80
        default:
            fatalError("Unrecognize index path row")
        }
    }
}
