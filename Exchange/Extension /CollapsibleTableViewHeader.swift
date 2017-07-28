//
//  CollapsibleTableViewHeader.swift
//  Exchange
//
//  Created by Quang Vu on 7/27/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit


protocol CollapsibleTableViewHeaderDelegate {
    func toggleSection(header: CollapsibleTableViewHeader, section: Int)
}

class CollapsibleTableViewHeader: UITableViewHeaderFooterView {

    var delegate: CollapsibleTableViewHeaderDelegate?
    var section: Int = 0
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CollapsibleTableViewHeader.selectHeaderAction(gestureRecognizer:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectHeaderAction(gestureRecognizer: UITapGestureRecognizer){
        let cell = gestureRecognizer.view as! CollapsibleTableViewHeader
        delegate?.toggleSection(header: self, section: cell.section)
    }
    
    func customInit(title: String ,section: Int, delegate: CollapsibleTableViewHeaderDelegate) {
        self.textLabel?.text = title
        self.section = section
        self.delegate = delegate
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel?.textColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        self.contentView.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
    }
}
