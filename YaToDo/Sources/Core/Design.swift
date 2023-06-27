//
//  Design.swift
//  YaToDo
//
//  Created by Владимир on 22.11.2022.
//

import UIKit

final class Design {
    
    typealias Padding = (small: CGFloat, base: CGFloat, medium: CGFloat, large: CGFloat)
    typealias ScreenSize = (width: CGFloat, half: CGFloat, quarter: CGFloat)
    typealias FontHeight = (small: CGFloat, system: CGFloat, label: CGFloat)
    
    let padding: Padding
    let screen: ScreenSize
    let fontHeight: FontHeight
    
    let simpleСellHeight: CGFloat
    
    
    
    static let shared = Design()
    
    private init() {
        padding = (small: 6, base: 12, medium: 16, large: 27)
        
        let width = UIScreen.main.bounds.size.width
        screen = (width: width, half: width/2, quarter: width/4)
        
        let smallSystemFont = UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize)
        let systemFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        let labelFont = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        
        fontHeight = (small: smallSystemFont.lineHeight.rounded(.up),
                      system: systemFont.lineHeight.rounded(.up),
                      label: labelFont.lineHeight.rounded(.up))
        
        simpleСellHeight = fontHeight.small + fontHeight.label + padding.small + padding.small
    }
}
