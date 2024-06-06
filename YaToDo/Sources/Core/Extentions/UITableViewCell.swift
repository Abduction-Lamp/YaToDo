//
//  UITableViewCell.swift
//  YaToDo
//
//  Created by Vladimir Lesnykh on 06.06.2024.
//

import UIKit

extension UITableViewCell {
    
    static var reuseIdentifier: String {
        String(describing: self)
    }
}
