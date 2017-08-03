//
//  ItemDetailPopOver.swift
//  Exchange
//
//  Created by Quang Vu on 8/2/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import Kingfisher

class ItemDetailPopOver: UIViewController {
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemDescription: UITextView!
    @IBOutlet weak var closePopUpButton: UIButton!
    var information: (String, String, String)?
    var fromRequestDetail = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        popUpView.layer.cornerRadius = 10
        popUpView.layer.masksToBounds = true
        itemImage.layer.zPosition = 0
        closePopUpButton.layer.zPosition = 1
        
        guard let info = information else {
            return
        }
        
        itemImage.kf.setImage(with: URL(string: info.0))
        itemDescription.text = info.1
        itemTitle.text = info.2
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    @IBAction func closePopUp(_ sender: UIButton) {
        if fromRequestDetail {
            performSegue(withIdentifier: "Unwind To Request Detail", sender: nil)
        } else {
            performSegue(withIdentifier: "Unwind To EX Confirm View", sender: nil)
        }
    }
}
