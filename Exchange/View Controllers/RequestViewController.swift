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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var request = [Request]() {
        didSet {
            tableView.reloadData()
        }
    }
    var fetchResult = [Request]()
    
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
        filteringRequestResult()
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
        activityIndicator.startAnimating()
        if index! == 0 {
            // Fetch outgoing request
            RequestService.retrieveOutgoingRequest(completionHandler: { [unowned self] (outgoingRequest) in
                self.fetchResult = outgoingRequest
                self.filteringRequestResult()
                self.activityIndicator.stopAnimating()
            })
            
        } else {
            // Fetch incoming request
            RequestService.retrieveIncomingRequest(completionHandler: { [unowned self] (incomingRequest) in
                self.fetchResult = incomingRequest
                self.filteringRequestResult()
                self.activityIndicator.stopAnimating()
            })
        }
    }
    
    func filteringRequestResult() {
        let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        emptyLabel.textAlignment = .center
        emptyLabel.font = UIFont(name: "Futura", size: 16)
        emptyLabel.textColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        emptyLabel.numberOfLines = 2
        
        switch self.requestSegmentControl.selectedSegmentIndex {
        case 0:
            self.request = fetchResult.filter { $0.status == "In Progress"}
            if self.request.count == 0 {
                emptyLabel.text = "No requested items"
                self.tableView.backgroundView = emptyLabel
            } else {
                self.tableView.backgroundView = nil
            }
        case 1:
            self.request = fetchResult.filter { $0.status != "In Progress"}
            if self.request.count == 0 {
                emptyLabel.text = "No completed items"
                self.tableView.backgroundView = emptyLabel
            } else {
                self.tableView.backgroundView = nil
            }
        default:
            break
        }
    }
}

extension RequestViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return request.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RequestTableViewCell = tableView.dequeueReusableCell()
        if index! == 0{
            cell.poster.text = request[indexPath.row].posterName
            cell.briefDescription.text = request[indexPath.row].firstPostTitle
        } else {
            cell.poster.text = request[indexPath.row].requesterName
            cell.briefDescription.text = request[indexPath.row].message
        }
        let imageURL = URL(string: request[indexPath.row].firstPostImageURL)
        cell.itemImage.kf.setImage(with: imageURL)
        cell.setStatus(status: request[indexPath.row].status)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "Show Request Detail", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
}
