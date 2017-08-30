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
    
    // Handle action when user accept the request
    @IBAction func confirmRequest(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: "You are about to accept this request", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            guard let request = self.request else {
                return
            }
            
            RequestService.updateRequest(for: request, withNewStatus: "Accepted", completion: { (success) in
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
    
    @IBAction func rejectRequest(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: "You are about to reject this request", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Yes", style: .default, handler: { [unowned self] (action) in
            guard let request = self.request else {
                return
            }
            
            RequestService.updateRequest(for: request, withNewStatus: "Rejected", completion: { (success) in
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
        let alertController = UIAlertController(title: nil, message: "You are about to cancel this request", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Yes", style: .default, handler: { [unowned self] (action) in
            guard let request = self.request else {
                return
            }
            
            // Display spinner
            RequestService.updateRequest(for: request, withNewStatus: "Cancelled", completion: { (success) in
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
    
    @IBAction func deleteRequest(_ sender: Any) {
        let confirmDeleteController = UIAlertController.init(title: nil, message: "Are you sure that you want to delete this request?", preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: "No", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction.init(title: "Yes", style: .default, handler: { [unowned self] (action) in
            UIApplication.shared.beginIgnoringInteractionEvents()
            let dispGroup = DispatchGroup()
            var requestRef: DatabaseReference
            
            // Unwrap request's key
            guard let request = self.request,
                let requestKey =  request.requestKey else {
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
            
            switch self.index! {
            case 0:
                requestRef = Database.database().reference().child("users/\(User.currentUser.uid)/Outgoing Request")
            case 1:
                requestRef = Database.database().reference().child("users/\(User.currentUser.uid)/Incoming Request")
            default:
                UIApplication.shared.endIgnoringInteractionEvents()
                fatalError("Unrecognized index")
            }
            
            dispGroup.enter()
            RequestService.updateRequest(for: request, withNewStatus: "Cancelled", completion: { (success) in
                if !success {
                    self.displayWarningMessage(message: "Failed to delete this request. Please check your network and try again")
                    dispGroup.leave()
                } else {
                    RequestService.deleteRequest(from: requestRef, requestID: requestKey, completionHandler: { (success) in
                        if success {
                            let alertController = UIAlertController.init(title: nil, message: "Request deleted.", preferredStyle: .alert)
                            let acknowledgeMessageAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                                self.performSegue(withIdentifier: "Back", sender: nil)
                            })
                            alertController.addAction(acknowledgeMessageAction)
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            self.displayWarningMessage(message: "Failed to delete this request. Please check your network and try again")
                        }
                        dispGroup.leave()
                    })
                }
            })
            
            
            dispGroup.notify(queue: .main, execute: {
                UIApplication.shared.endIgnoringInteractionEvents()
            })
        })
        
        confirmDeleteController.addAction(confirmAction)
        confirmDeleteController.addAction(cancelAction)
        self.present(confirmDeleteController, animated: true, completion: nil)
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
            let cell: PartnerTableViewCell = tableView.dequeueReusableCell()
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
            let cell: CollectionTableViewCell = tableView.dequeueReusableCell()
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
            let cell: CollectionTableViewCell = tableView.dequeueReusableCell()
            if let request = request {
                cell.controller = self
                cell.itemList = request.posterItemsData
                cell.status = request.status
            }
            return cell
            
        case 4:
            if index! == 0 {
                let cell: CancelRequestCell = tableView.dequeueReusableCell()
                return cell
            } else {
                let cell: ButtonTableViewCell = tableView.dequeueReusableCell()
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
