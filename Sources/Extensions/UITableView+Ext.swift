//
//  UITableViewCell+Ext.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/16/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {
    class var reuseIdentifier: String {
        return "\(self)"
    }
}

extension UITableViewHeaderFooterView {
    class var reuseIdentifier: String {
        return "\(self)"
    }
}

extension UITableView {
    func register<E: UITableViewCell>(_ type: E.Type) {
        let reuseIdentifier = type.reuseIdentifier
        
        if Bundle.main.path(forResource: reuseIdentifier, ofType: "nib") != nil {
            register(UINib(nibName: reuseIdentifier, bundle: nil),
                     forCellReuseIdentifier: reuseIdentifier)
        }
        else {
            register(type, forCellReuseIdentifier: reuseIdentifier)
        }
    }
    
    func register<E: UITableViewHeaderFooterView>(_ type: E.Type) {
        let reuseIdentifier = type.reuseIdentifier
        
        if Bundle.main.path(forResource: reuseIdentifier, ofType: "nib") != nil {
            register(UINib(nibName: reuseIdentifier, bundle: nil),
                     forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        }
        else {
            register(type, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        }
    }
    
    func dequeueReusableCell<E: UITableViewCell>(with type: E.Type,
                                                 for indexPath: IndexPath) -> E {
        return dequeueReusableCell(withIdentifier: type.reuseIdentifier, for: indexPath) as! E
    }
    
    func dequeueReusableHeaderFooterView<E: UITableViewHeaderFooterView>(with type: E.Type) -> E {
        return dequeueReusableHeaderFooterView(withIdentifier: type.reuseIdentifier) as! E
    }
}
