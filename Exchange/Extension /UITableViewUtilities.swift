//
//  UITableViewUtilities.swift
//  Exchange
//
//  Created by Quang Vu on 8/26/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit


protocol CellIdentifiable {
    static var cellIdentifier: String { get }
}

// Extend our protocol to define a default value for our properpty
extension CellIdentifiable where Self: UITableViewCell {
    
    // Return the name of the custom table view cell class -> prevent typo when typing cell identifier
    static var cellIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: CellIdentifiable {}

extension UITableView {
    
    // Define generic func with generic type of UITableVIewCell and that it conforms to CellIdentifiable
    func dequeueReusableCell<T: UITableViewCell>() -> T where T: CellIdentifiable {
        // Unwrap the cell
        print(T.cellIdentifier)
        guard let cell = dequeueReusableCell(withIdentifier: T.cellIdentifier) as? T else {
            fatalError("Error dequeuing cell for identifier \(T.cellIdentifier)")
        }
        
        return cell
    }
}
