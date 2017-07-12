//
//  MarketplaceHeaderView.swift
//  Exchange
//
//  Created by Quang Vu on 7/8/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class MarketplaceHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var searchBar: UISearchBar!
    override func awakeFromNib() {
        super.awakeFromNib()
        let searchBarTextField = searchBar.value(forKey: "searchField") as? UITextField
        searchBarTextField?.textColor = UIColor.white
        hideKeyboard()
    }
}

