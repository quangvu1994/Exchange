//
//  MainTabBarController.swift
//  Exchange
//
//  Created by Quang Vu on 7/11/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.unselectedItemTintColor = UIColor.black
        tabBar.tintColor = UIColor(red: 210/255, green: 104/255, blue: 84/255, alpha: 1.0)
    }
}
