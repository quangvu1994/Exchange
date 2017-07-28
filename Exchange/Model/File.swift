//
//  File.swift
//  Exchange
//
//  Created by Quang Vu on 7/27/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

struct Section {
    var name: String
    var items: [Request]
    var collapse: Bool
    
    init(name: String, items: [Request], collapse: Bool = false){
        self.name = name
        self.items = items
        self.collapse = collapse
    }
}
