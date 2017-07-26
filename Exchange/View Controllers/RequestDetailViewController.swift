//
//  ConfirmedRequestViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/20/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import FirebaseDatabase

class RequestDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var request: Request?
    var segmentIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }
    
    @IBAction func confirmRequest(_ sender: UIButton) {
        // Update the request status on the database + all items' availability + remove user from the requested by field
        guard let request = request,
            let requestRef = request.requestKey else {
            return
        }
        
        var data: [String: Any] = [
            "Requests/\(requestRef)/status": "Confirmed"
        ]
        let posterItemsKey = Array(request.posterItemsData.keys)
        for itemRef in posterItemsKey {
            data["allItems/\(itemRef)/availability"] = false
            data["allItems/\(itemRef)/requested_by/\(request.posterID)"] = [:]
        }
        
        // While this is going on, we can also display a spinner
        let dispatchGroup = DispatchGroup()
        var success = true
        dispatchGroup.enter()
        Database.database().reference().updateChildValues(data, withCompletionBlock: { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success = false
                dispatchGroup.leave()
                return
            }
            dispatchGroup.leave()
        })
        
        dispatchGroup.notify(queue: .main, execute: {
            if success {
                let alertController
                    = UIAlertController(title: nil, message: "Request Confirmed!", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                let alertController
                    = UIAlertController(title: nil, message: "Fail to confirm request! Check your network and retry again", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        })
        
    }
    @IBAction func rejectRequest(_ sender: UIButton) {
        // Update the request status on the database + all items' availability + remove user from the requested by field
        guard let request = request,
            let requestRef = request.requestKey else {
                return
        }
        
        var data: [String: Any] = [
            "Requests/\(requestRef)/status": "Rejected"
        ]
        let posterItemsKey = Array(request.posterItemsData.keys)
        for itemRef in posterItemsKey {
            data["allItems/\(itemRef)/requested_by/\(request.posterID)"] = [:]
        }
        
        let requesterItemsKey = Array(request.requesterItemsData.keys)
        for itemRef in requesterItemsKey {
            data["allItems/\(itemRef)/requested_by/\(request.requesterID)"] = [:]
        }
        
        // While this is going on, we can also display a spinner
        let dispatchGroup = DispatchGroup()
        var success = true
        dispatchGroup.enter()
        Database.database().reference().updateChildValues(data, withCompletionBlock: { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success = false
                dispatchGroup.leave()
                return
            }
            dispatchGroup.leave()
        })
        
        dispatchGroup.notify(queue: .main, execute: {
            if success {
                let alertController
                    = UIAlertController(title: nil, message: "Request Rejected!", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                let alertController
                    = UIAlertController(title: nil, message: "Fail to reject request! Check your network and retry again", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        })
        
    }
}

extension RequestDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Trade Partner Info", for: indexPath) as! PartnerTableViewCell
            if let request = request,
                let segmentIndex = segmentIndex {
                cell.address.text = request.tradeLocation
                cell.message.text = request.message
                if segmentIndex == 0 {
                    cell.username.text = request.posterName
                    cell.phoneNumber.text = request.posterPhone
                } else {
                    cell.username.text = request.requesterName
                    cell.phoneNumber.text = request.requesterPhone
                }
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Collection View Cell", for: indexPath) as! CollectionTableViewCell
            if let request = request {
                cell.itemList = request.requesterItemsData
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Trade For", for: indexPath)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Collection View Cell", for: indexPath) as! CollectionTableViewCell
            if let request = request {
                cell.itemList = request.posterItemsData
            }
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Button Cell", for: indexPath) as! ButtonTableViewCell
            return cell
            
        default:
            fatalError("Unrecognized index path row")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 450
        case 1:
            return 150
        case 2:
            return 40
        case 3:
            return 150
        case 4:
            return 80
        default:
            fatalError("Unrecognized index path row")
        }
    }
}
