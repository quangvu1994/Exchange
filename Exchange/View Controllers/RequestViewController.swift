//
//  RequestViewController.swift
//  Exchange
//
//  Created by Quang Vu on 7/17/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import Kingfisher

class RequestViewController: UIViewController {
    
    @IBOutlet weak var requestSegmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var request = [Request]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var index: Int?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        fetchingRequest()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        requestSegmentControl.layer.cornerRadius = 0
        requestSegmentControl.layer.borderColor = UIColor(red: 210/255, green: 104/255, blue: 84/255, alpha: 1.0).cgColor
        requestSegmentControl.layer.borderWidth = 1
        // Auto resizing the height of the cell
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if index! == 0 {
            self.title = "Outgoing Requests"
        } else if index! == 1 {
            self.title = "Incoming Requests"
        }
    }
    
    @IBAction func switchRequestType(_ sender: UISegmentedControl) {
        fetchingRequest()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "Show Request Detail" {
                let detailViewController = segue.destination as! RequestDetailViewController
                detailViewController.request = request[tableView.indexPathForSelectedRow!.row]
                detailViewController.index = index
            }
        }
    }
    
    @IBAction func unwindToRequestViewController(_ sender: UIStoryboardSegue) {
        print("unwinded")
    }
    
    func fetchingRequest() {
        let dispatchGroup = DispatchGroup()
        if index! == 0 {
            // Fetch outgoing request
            dispatchGroup.enter()
            RequestService.retrieveOutgoingRequest(completionHandler: { [weak self] (outgoingRequest) in
                self?.request = outgoingRequest
                dispatchGroup.leave()
            })
        } else {
            // Fetch incoming request
            dispatchGroup.enter()
            RequestService.retrieveIncomingRequest(completionHandler: { [weak self] (incomingRequest) in
                self?.request = incomingRequest
                dispatchGroup.leave()
            })
        }
        dispatchGroup.notify(queue: .main, execute: {
            switch self.requestSegmentControl.selectedSegmentIndex {
            case 0:
                self.request = self.request.filter { $0.status != "Confirmed"}
            case 1:
                self.request = self.request.filter { $0.status == "Confirmed"}
            default:
                break
            }
        })
    }
}

extension RequestViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return request.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Request Cell", for: indexPath) as! RequestTableViewCell
        if index! == 0{
            cell.poster.text = request[indexPath.row].posterName
            cell.briefDescription.text = request[indexPath.row].firstPostTitle
        } else {
            cell.poster.text = request[indexPath.row].requesterName
            cell.briefDescription.text = request[indexPath.row].message
        }
        let imageURL = URL(string: request[indexPath.row].firstPostImageURL)
        cell.itemImage.kf.setImage(with: imageURL)
        cell.status.text = request[indexPath.row].status
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if requestSegmentControl.selectedSegmentIndex == 2 {
            //segue to confirmation page
        } else {
            self.performSegue(withIdentifier: "Show Request Detail", sender: nil)

        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
}
