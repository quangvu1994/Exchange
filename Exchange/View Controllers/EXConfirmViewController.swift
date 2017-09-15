//
//  EXConfirmViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/13/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import OneSignal

class EXConfirmViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var requesterItems = [Post]()
    var posterItems = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        hideKeyboardOnTap()
    }
    
    @IBAction func sendRequest(_ sender: UIButton) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let messageCell = tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as! EXTableDescriptionCell
        let cashCell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! EXCashCell
        
        // Write the request to our database
        let request = Request(requesterItems: requesterItems, posterItems: posterItems)
        // Safe to force unwrap
        request.message = messageCell.getInformation()!
        if cashCell.amountField.text != "" {
            request.cashAmount = cashCell.amountField.text!
        }

        RequestService.writeNewRequest(for: User.currentUser.uid, and: posterItems[0].poster.uid, with: request, completionHandler: { [unowned self] (success) in
            if !success {
                self.displayWarningMessage(message: "Unable to send request, please check your network and try again")
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
            let alertController = UIAlertController(title: nil, message: "Your exchange request has been sent!", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                self.performSegue(withIdentifier: "Finish Exchange Sequence", sender: nil)
            })
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            // Send a notification to the poster
            OneSignal.postNotification(["contents": ["en": "\(User.currentUser.username) just send you a new request for your items. Check your incoming requests!)"],
                                        "include_player_ids": ["\(self.posterItems[0].poster.oneSignalID)"]])
            UIApplication.shared.endIgnoringInteractionEvents()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "Open Item Detail Popup" {
                let popUpDestination = segue.destination as! ItemDetailPopOver
                guard let infoTuple = sender as? (String, String, String) else {
                    return
                }
                popUpDestination.information = infoTuple
            }
        }
    }
    
    @IBAction func unwindToEXConfirmView(_ sender: UIStoryboardSegue) {
        // do nothing
    }
}

extension EXConfirmViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell: EXTableCollectionCell = tableView.dequeueReusableCell()
            cell.itemList = requesterItems
            cell.controller = self
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Trade For", for: indexPath)
            return cell
            
        case 2:
            let cell: EXTableCollectionCell = tableView.dequeueReusableCell()
            cell.itemList = posterItems
            cell.controller = self
            return cell
            
        case 3:
            let cell: EXCashCell = tableView.dequeueReusableCell()
            return cell
        case 4:
            let cell: EXTableDescriptionCell = tableView.dequeueReusableCell()
            cell.titleText.text = "Say something to the owner"
            cell.descriptionText.textColor = UIColor.lightGray
            cell.descriptionText.text = "Your message"
            cell.placeHolder = "Your message"
            cell.view = view
            return cell
        case 5:
            let cell: EXTableButtonCell = tableView.dequeueReusableCell()
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

extension EXConfirmViewController: DisplayItemDetailHandler {
    func displayWithIndex(index: Int) {
        // Do nothing
    }
    
    func displayWithFullInfo(imageURL: String, itemDescription: String, itemTitle: String) {
        self.performSegue(withIdentifier: "Open Item Detail Popup", sender: (imageURL, itemDescription, itemTitle))
    }
}
