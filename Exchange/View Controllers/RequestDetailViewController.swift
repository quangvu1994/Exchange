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
    var index: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        self.navigationItem.title = request?.status
    }
    
    @IBAction func confirmRequest(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            // Update the request status on the database + all items' availability + remove user from the requested by field
            guard let request = self.request,
                let requestRef = request.requestKey else {
                    return
            }
            
            var data: [String: Any] = [
                "Requests/\(requestRef)/status": "Accepted"
            ]
            
            let posterItemsKey = Array(request.posterItemsData.keys)
            for itemRef in posterItemsKey {
                data["allItems/\(itemRef)/availability"] = false
                data["allItems/\(itemRef)/requested_by/\(request.requesterID)"] = [:]
            }
            
            let requesterItemsKey = Array(request.requesterItemsData.keys)
            for itemRef in requesterItemsKey {
                data["allItems/\(itemRef)/availability"] = false
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
                        = UIAlertController(title: nil, message: "Request Accepted!", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                        self.performSegue(withIdentifier: "Back", sender: nil)
                    })
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
        })
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func rejectRequest(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            // Update the request status on the database + all items' availability + remove user from the requested by field
            guard let request = self.request,
                let requestRef = request.requestKey else {
                    return
            }
            
            var data: [String: Any] = [
                "Requests/\(requestRef)/status": "Rejected"
            ]
            let posterItemsKey = Array(request.posterItemsData.keys)
            for itemRef in posterItemsKey {
                data["allItems/\(itemRef)/requested_by/\(request.requesterID)"] = [:]
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
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in 
                        self.performSegue(withIdentifier: "Back", sender: nil)
                    })
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
        })
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func cancelRequest(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            // Update the request status on the database + all items' availability + remove user from the requested by field
            guard let request = self.request,
                let requestRef = request.requestKey else {
                    return
            }
            
            var data: [String: Any] = [
                "Requests/\(requestRef)/status": "Cancelled"
            ]
            let posterItemsKey = Array(request.posterItemsData.keys)
            for itemRef in posterItemsKey {
                data["allItems/\(itemRef)/requested_by/\(request.requesterID)"] = [:]
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
                        = UIAlertController(title: nil, message: "Request Cancelled!", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                        self.performSegue(withIdentifier: "Back", sender: nil)
                    })
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
        })
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "Item Detail Pop Over" {
                guard let infoTuple = sender as? (String, String, String) else {
                    return
                }
                let destination = segue.destination as! ItemDetailPopOver
                destination.information = infoTuple
                destination.fromRequestDetail = true
                self.tabBarController?.tabBar.isHidden = true
            }
        }
    }
    
    @IBAction func unwindToRequestDetail(_ sender: UIStoryboardSegue) {
        self.tabBarController?.tabBar.isHidden = false
    }
}

extension RequestDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let request = request else {
            fatalError("No request found")
        }
        
        if request.status != "In Progress" {
            return 4
        } else {
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Trade Partner Info", for: indexPath) as! PartnerTableViewCell
            if let request = request,
                let index = index {
                cell.address.text = request.tradeLocation
                cell.message.text = request.message
                if index == 0 {
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
                cell.controller = self
                cell.itemList = request.requesterItemsData
                cell.status = request.status
                if request.cashAmount != "" {
                    cell.cashAmount = request.cashAmount
                }
            }
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Trade For", for: indexPath)
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Collection View Cell", for: indexPath) as! CollectionTableViewCell
            if let request = request {
                cell.controller = self
                cell.itemList = request.posterItemsData
                cell.status = request.status
            }
            return cell
            
        case 4:
            if index! == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cancel Request Cell", for: indexPath) as! CancelRequestCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Button Cell", for: indexPath) as! ButtonTableViewCell
                return cell
            }
            
        default:
            fatalError("Unrecognized index path row")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 450
        case 1:
            return 200
        case 2:
            return 20
        case 3:
            return 200
        case 4:
            return 80
        default:
            fatalError("Unrecognized index path row")
        }
    }
}

extension RequestDetailViewController: DisplayItemDetailHandler {

    func displayWithIndex(index: Int) {
        // Optional don't need this
    }
    
    func displayWithFullInfo(imageURL: String, itemDescription: String, itemTitle: String) {
        self.performSegue(withIdentifier: "Item Detail Pop Over", sender: (imageURL, itemDescription, itemTitle))
    }
}
