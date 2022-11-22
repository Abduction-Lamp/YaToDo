//
//  Design.swift
//  YaToDo
//
//  Created by Владимир on 22.11.2022.
//

import UIKit

final class Design {
    typealias Padding = (small: CGFloat, medium: CGFloat, large: CGFloat)
    typealias Screen = (width: CGFloat, half: CGFloat, quarter: CGFloat)
    
    
    let padding: Padding
    let screen: Screen

    
    static let shared = Design()
    private init() {
        padding = (small: 6, medium: 16, large: 27)
        
        let width = UIScreen.main.bounds.size.width
        screen = (width: width, half: width/2, quarter: width/4)
    }
}
