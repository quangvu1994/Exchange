//
//  StoryboardUtilities.swift
//  Exchange
//
//  Created by Quang Vu on 7/4/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    enum EXType: String {
        case login
        case main
        
        var filename: String {
            return rawValue.capitalized
        }
    }
    
    convenience init(type: EXType, bundle: Bundle? = nil) {
        self.init(name: type.filename, bundle: bundle)
    }
    
    static func initialViewController(type: EXType) -> UIViewController {
        let storyboard = UIStoryboard(type: type)
        if let initialViewController = storyboard.instantiateInitialViewController() {
            return initialViewController
        }else {
            fatalError("Fail to open Login screen because there is no initial view controller")
        }
    }
}
