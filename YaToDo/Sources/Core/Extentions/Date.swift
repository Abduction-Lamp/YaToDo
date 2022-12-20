//
//  Date.swift
//  YaToDo
//
//  Created by Владимир on 13.12.2022.
//

import Foundation

extension Date {
    
    public func toString(format: String = "d MMMM yyyy, HH:mm") -> String {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: NSLocalizedString("General.Locale.Identifier", comment: "Locale Identifier"))
        formatter.dateFormat = format

        return formatter.string(from: self)
    }
}
